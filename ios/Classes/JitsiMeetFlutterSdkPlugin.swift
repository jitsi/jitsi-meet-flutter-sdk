import Flutter
import UIKit
import JitsiMeetSDK

public class JitsiMeetFlutterSdkPlugin: NSObject, FlutterPlugin {
    var jitsiMeetViewController: JitsiMeetViewController?
    var flutterViewController: UIViewController
    
    init(flutterViewController: UIViewController) {
        self.flutterViewController = flutterViewController
    }
  
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "jitsi_meet_flutter_sdk", binaryMessenger: registrar.messenger())
        let flutterViewController: UIViewController = (UIApplication.shared.delegate?.window??.rootViewController)!
        let instance = JitsiMeetFlutterSdkPlugin(flutterViewController: flutterViewController)
        registrar.addMethodCallDelegate(instance, channel: channel)
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
            builder.room = "testgabigabi"
        }
        jitsiMeetViewController = JitsiMeetViewController.init(options: options)
        jitsiMeetViewController!.modalPresentationStyle = .overFullScreen
        flutterViewController.present(jitsiMeetViewController!, animated: false)
        result(nil)
    }
}
