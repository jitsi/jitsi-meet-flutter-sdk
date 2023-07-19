import Flutter
import UIKit
import JitsiMeetSDK

public class JitsiMeetFlutterSdkPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
    var flutterViewController: UIViewController
    var jitsiMeetViewController: JitsiMeetViewController?
    var eventSink: FlutterEventSink?

    init(flutterViewController: UIViewController) {
        self.flutterViewController = flutterViewController
    }

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "jitsi_meet_flutter_sdk", binaryMessenger: registrar.messenger())
        let flutterViewController: UIViewController = (UIApplication.shared.delegate?.window??.rootViewController)!
        let instance = JitsiMeetFlutterSdkPlugin(flutterViewController: flutterViewController)
        registrar.addMethodCallDelegate(instance, channel: channel)

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
        default:
          result(FlutterMethodNotImplemented)
        }
    }

    private func join(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let options = JitsiMeetConferenceOptions.fromBuilder { (builder) in
            builder.room = "testgabigabi2"
        }
        
        jitsiMeetViewController = JitsiMeetViewController.init(options: options, eventSink: eventSink!)

        jitsiMeetViewController!.modalPresentationStyle = .overFullScreen
        flutterViewController.present(jitsiMeetViewController!, animated: true)
        result(nil)
    }

    private func hangUp(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        jitsiMeetViewController?.jitsiMeetView?.hangUp()
        result(nil)
    }

    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        return nil
    }
}
