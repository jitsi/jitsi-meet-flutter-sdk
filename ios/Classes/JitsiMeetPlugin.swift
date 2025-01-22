import Flutter
import UIKit
import JitsiMeetSDK

public class JitsiMeetPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
    var flutterViewController: UIViewController
    var jitsiNativeView: JitsiNativeView?
    var eventSink: FlutterEventSink?

    init(flutterViewController: UIViewController) {
        self.flutterViewController = flutterViewController
    }

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "jitsi_meet_flutter_sdk", binaryMessenger: registrar.messenger())
        let flutterViewController: UIViewController = (UIApplication.shared.delegate?.window??.rootViewController)!
        let instance = JitsiMeetPlugin(flutterViewController: flutterViewController)
        registrar.addMethodCallDelegate(instance, channel: channel)

        let eventChannel = FlutterEventChannel(name: "jitsi_meet_flutter_sdk_events", binaryMessenger: registrar.messenger())
        eventChannel.setStreamHandler(instance)
        
        let nativeViewFactory = JitsiNativeViewFactory(
            messenger: registrar.messenger(),
            eventSinkProvider: { instance.eventSink },
            plugin: instance
        )
        registrar.register(nativeViewFactory, withId: "JitsiNativeView")
    }
    
    func jitsiNativeViewCreated(_ view: JitsiNativeView) {
        self.jitsiNativeView = view
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
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
        default:
          result(FlutterMethodNotImplemented)
        }
    }

    private func hangUp(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        jitsiNativeView?.jitsiMeetView?.hangUp()
        result("Successfully hung up")
    }

    private func setAudioMuted(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as! [String: Any]
        let muted = arguments["muted"] as! Bool
        jitsiNativeView?.jitsiMeetView?.setAudioMuted(muted)
        result("Successfully set audio \(muted)")
    }

    private func setVideoMuted(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as! [String: Any]
        let muted = arguments["muted"] as! Bool
        jitsiNativeView?.jitsiMeetView?.setVideoMuted(muted)
        result("Successfully set video \(muted)")
    }

    private func sendEndpointTextMessage(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as! [String: Any]
        let to = arguments["to"] as? String
        let message: String = arguments["message"] as! String
        jitsiNativeView?.jitsiMeetView?.sendEndpointTextMessage(message, to)
        result("Successfully send endpoint text message \(to)")
    }

    private func toggleScreenShare(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as! [String: Any]
        let enabled = arguments["enabled"] as! Bool
        jitsiNativeView?.jitsiMeetView?.toggleScreenShare(enabled)
        result("Successfully toggled screen share \(enabled)")
    }

    private func openChat(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as! [String: Any]
        let to = arguments["to"] as? String
        jitsiNativeView?.jitsiMeetView?.openChat(to)
        result("Successfully opened chat \(to)")
    }

    private func sendChatMessage(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as! [String: Any]
        let to = arguments["to"] as? String
        let message: String = arguments["message"] as! String
        jitsiNativeView?.jitsiMeetView?.sendChatMessage(message, to)
        result("Successfully sent chat message \(to)")
    }

    private func closeChat(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        jitsiNativeView?.jitsiMeetView?.closeChat()
        result("Successfully closed chat")
    }

    private func retrieveParticipantsInfo(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        jitsiNativeView?.jitsiMeetView?.retrieveParticipantsInfo({ (data:[Any]?) in self.eventSink!(["event": "participantsInfoRetrieved", "data": data])})
        result("Successfully retrieved participants info")
    }

    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        return nil
    }
}
