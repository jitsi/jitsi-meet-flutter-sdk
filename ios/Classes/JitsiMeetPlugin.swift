import Flutter
import UIKit
import JitsiMeetSDK

public class JitsiMeetPlugin: NSObject, FlutterPlugin, FlutterStreamHandler, FlutterSceneLifeCycleDelegate {
    weak var registrar: FlutterPluginRegistrar?
    var jitsiMeetViewController: JitsiMeetViewController?
    var eventSink: FlutterEventSink?

    init(registrar: FlutterPluginRegistrar) {
        self.registrar = registrar
    }

    private var flutterViewController: UIViewController? {
        registrar?.viewController
    }

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "jitsi_meet_flutter_sdk", binaryMessenger: registrar.messenger())
        let instance = JitsiMeetPlugin(registrar: registrar)
        registrar.addMethodCallDelegate(instance, channel: channel)
        registrar.addSceneDelegate(instance)

        let eventChannel = FlutterEventChannel(name: "jitsi_meet_flutter_sdk_events", binaryMessenger: registrar.messenger())
        eventChannel.setStreamHandler(instance)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
            return
        case "join":
            join(call, result: result)
            return
        case "hangUp":
            hangUp(call, result: result)
            return
        case "setAudioMuted":
            setAudioMuted(call, result: result)
            return
        case "setVideoMuted":
            setVideoMuted(call, result: result)
            return
        case "sendEndpointTextMessage":
            sendEndpointTextMessage(call, result: result)
            return
        case "toggleScreenShare":
            toggleScreenShare(call, result: result)
            return
        case "openChat":
            openChat(call, result: result)
            return
        case "sendChatMessage":
            sendChatMessage(call, result: result)
            return
        case "closeChat":
            closeChat(call, result: result)
            return
        case "retrieveParticipantsInfo":
            retrieveParticipantsInfo(call, result: result)
            return
        case "enterPiP":
            enterPiP(call, result: result)
            return
        default:
          result(FlutterMethodNotImplemented)
        }
    }

    private func join(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as! [String: Any]
        let serverURL = arguments["serverURL"] as? String
        let room = arguments["room"] as? String
        let token = arguments["token"] as? String
        let configOverrides = arguments["configOverrides"] as? Dictionary<String, Any>
        let featureFlags = arguments["featureFlags"] as? Dictionary<String, Any>
        let rawUserInfo = arguments["userInfo"] as! [String: Any]
        let displayName = rawUserInfo["displayName"] as? String
        let email = rawUserInfo["email"] as? String
        var avatar: URL? = nil
        if rawUserInfo["avatar"] as? String != nil {
            avatar = URL(string: rawUserInfo["avatar"] as! String)
        }
        var userInfo: JitsiMeetUserInfo? = nil
        if (displayName != nil || email != nil || avatar != nil) {
            userInfo = JitsiMeetUserInfo(displayName: displayName, andEmail: email, andAvatar: avatar)
        }

        let options = JitsiMeetConferenceOptions.fromBuilder { (builder) in
            if (serverURL != nil) {
                builder.serverURL = URL(string: serverURL as! String)
            }
            if (room != nil) {
                builder.room = room;
            }
            if (token != nil) {
                builder.token = token;
            }
            configOverrides?.forEach { key, value in
                builder.setConfigOverride(key, withValue: value);
            }
            featureFlags?.forEach { key, value in
                builder.setFeatureFlag(key, withValue: value);
            }
            if (userInfo != nil) {
                builder.userInfo = userInfo
            }
        }

        guard let viewController = flutterViewController else {
            result(FlutterError(
                code: "UNAVAILABLE",
                message: "Flutter view controller is not available (UIScene lifecycle).",
                details: nil
            ))
            return
        }
        guard let sink = eventSink else {
            result(FlutterError(
                code: "NO_EVENT_SINK",
                message: "Event stream not listened to. Call JitsiMeetEventListener first.",
                details: nil
            ))
            return
        }
        jitsiMeetViewController = JitsiMeetViewController.init(options: options, eventSink: sink)
        jitsiMeetViewController!.modalPresentationStyle = .overFullScreen
        viewController.present(jitsiMeetViewController!, animated: true)
        result("Successfully joined meeting \(room ?? "")")
    }

    private func hangUp(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        jitsiMeetViewController?.jitsiMeetView?.hangUp()
        result("Successfully hung up")
    }

    private func setAudioMuted(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as! [String: Any]
        let muted = arguments["muted"] as! Bool
        jitsiMeetViewController?.jitsiMeetView?.setAudioMuted(muted)
        result("Successfully set audio \(muted)")
    }

    private func setVideoMuted(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as! [String: Any]
        let muted = arguments["muted"] as! Bool
        jitsiMeetViewController?.jitsiMeetView?.setVideoMuted(muted)
        result("Successfully set video \(muted)")
    }

    private func sendEndpointTextMessage(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as! [String: Any]
        let to = arguments["to"] as? String
        let message: String = arguments["message"] as! String
        jitsiMeetViewController?.jitsiMeetView?.sendEndpointTextMessage(message, to)
        result("Successfully send endpoint text message \(to)")
    }

    private func toggleScreenShare(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as! [String: Any]
        let enabled = arguments["enabled"] as! Bool
        jitsiMeetViewController?.jitsiMeetView?.toggleScreenShare(enabled)
        result("Successfully toggled screen share \(enabled)")
    }

    private func openChat(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as! [String: Any]
        let to = arguments["to"] as? String
        jitsiMeetViewController?.jitsiMeetView?.openChat(to)
        result("Successfully opened chat \(to)")
    }

    private func sendChatMessage(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as! [String: Any]
        let to = arguments["to"] as? String
        let message: String = arguments["message"] as! String
        jitsiMeetViewController?.jitsiMeetView?.sendChatMessage(message, to)
        result("Successfully sent chat message \(to)")
    }

    private func closeChat(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        jitsiMeetViewController?.jitsiMeetView?.closeChat()
        result("Successfully closed chat")
    }

    private func retrieveParticipantsInfo(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        jitsiMeetViewController?.jitsiMeetView?.retrieveParticipantsInfo({ [weak self] (data: [Any]?) in
            self?.eventSink?(["event": "participantsInfoRetrieved", "data": data ?? []])
        })
        result("Successfully retrieved participants info")
    }

    private func enterPiP(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        jitsiMeetViewController?.enterPicture(inPicture: [:])
        result("Successfully entered Picture in Picture")
    }

    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        return nil
    }
}
