import UIKit
import Flutter
import JitsiMeetSDK

class JitsiNativeViewFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger
    private var eventSinkProvider: () -> FlutterEventSink?
    private weak var plugin: JitsiMeetPlugin?
    
    init(messenger: FlutterBinaryMessenger, eventSinkProvider: @escaping () -> FlutterEventSink?, plugin: JitsiMeetPlugin?) {
        self.messenger = messenger
        self.eventSinkProvider = eventSinkProvider
        self.plugin = plugin
        super.init()
    }
    
    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        let arguments = args as! [String: Any]
        let roomUrl = arguments["roomUrl"] as! String
        
        let options = try! JitsiMeetConferenceOptions.fromUrl(roomUrl)
        
        let view = JitsiNativeView(
            options: options,
            eventSink: eventSinkProvider()
        )
        
        plugin?.jitsiNativeViewCreated(view)
        
        return view
    }
    
    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}

extension JitsiMeetConferenceOptions {
    static func fromUrl(_ urlString: String) throws -> JitsiMeetConferenceOptions {
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "Invalid URL", code: -1, userInfo: nil)
        }
        
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let domain = url.host ?? ""
        let roomName = url.pathComponents.last ?? ""
        
        if roomName.isEmpty {
            throw NSError(domain: "Invalid room name", code: -1, userInfo: nil)
        }
        
        let options = JitsiMeetConferenceOptions.fromBuilder { builder in
            builder.room = roomName
            builder.serverURL = URL(string: "https://\(domain)")
            
            // Парсинг query-параметров
            components?.queryItems?.forEach { item in
                let key = item.name
                let value = item.value ?? ""
                
                if key.starts(with: "userInfo.") {
                    switch key {
                    case "userInfo.displayName":
                        builder.userInfo?.displayName = value
                    case "userInfo.email":
                        builder.userInfo?.email = value
                    case "userInfo.avatar":
                        builder.userInfo?.avatar = URL(string: value)
                    default:
                        break
                    }
                } else if key.starts(with: "config.") {
                    switch key {
                    case "config.startWithAudioMuted":
                        builder.setConfigOverride("startWithAudioMuted", withValue: value == "true")
                    case "config.startWithVideoMuted":
                        builder.setConfigOverride("startWithVideoMuted", withValue: value == "true")
                    case "config.disableInitialGUM":
                        builder.setConfigOverride("disableInitialGUM", withValue: value == "true")
                    case "config.toolbarButtons":
                        if let buttons = try? JSONSerialization.jsonObject(with: Data(value.utf8), options: []) as? [String] {
                            builder.setConfigOverride("toolbarButtons", withValue: buttons)
                        }
                    default:
                        break
                    }
                } else if key.starts(with: "interfaceConfigOverwrite.") {
                    switch key {
                    case "interfaceConfigOverwrite.TOOLBAR_ALWAYS_VISIBLE":
                        builder.setConfigOverride("toolbarAlwaysVisible", withValue: value == "true")
                    case "interfaceConfigOverwrite.DISABLE_JOIN_LEAVE_NOTIFICATIONS":
                        builder.setConfigOverride("disableJoinLeaveNotifications", withValue: value == "true")
                    default:
                        break
                    }
                } else {
                    builder.setFeatureFlag(key, withValue: value == "true")
                }
            }
        }
        
        return options
    }
}
