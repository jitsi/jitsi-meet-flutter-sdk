import UIKit
import Flutter
import JitsiMeetSDK

class JitsiNativeView: UIView, FlutterPlatformView {
    func view() -> UIView { self }
    
    
    var jitsiMeetView: JitsiMeetView?
    let options: JitsiMeetConferenceOptions
    let eventSink: FlutterEventSink?
    
    init(options: JitsiMeetConferenceOptions, eventSink: FlutterEventSink?) {
        self.options = options
        self.eventSink = eventSink
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }
    
    private func setupView() {
        openJitsiMeet()
    }
    
    private func openJitsiMeet() {
        cleanUp()
        
        jitsiMeetView = JitsiMeetView()
        jitsiMeetView?.frame = bounds
        addSubview(jitsiMeetView!)
        
        jitsiMeetView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        jitsiMeetView?.delegate = self
        jitsiMeetView?.join(options)
    }
    
    private func cleanUp() {
        jitsiMeetView?.removeFromSuperview()
        jitsiMeetView = nil
    }
}

extension JitsiNativeView: JitsiMeetViewDelegate {
    func conferenceJoined(_ data: [AnyHashable : Any]) {
        eventSink?(["event": "conferenceJoined", "data": data])
    }
    
    func conferenceTerminated(_ data: [AnyHashable: Any]) {
        eventSink?(["event": "conferenceTerminated", "data": data])
    }
    
    func conferenceWillJoin(_ data: [AnyHashable : Any]) {
        eventSink?(["event": "conferenceWillJoin", "data": data])
    }
    
    func participantJoined(_ data: [AnyHashable : Any]) {
        eventSink?(["event": "participantJoined", "data": data])
    }
    
    func participantLeft(_ data: [AnyHashable : Any]) {
        eventSink?(["event": "participantLeft", "data": data])
    }
    
    func audioMutedChanged(_ data: [AnyHashable : Any]) {
        eventSink?(["event": "audioMutedChanged", "data": data])
    }
    
    func videoMutedChanged(_ data: [AnyHashable : Any]) {
        eventSink?(["event": "videoMutedChanged", "data": data])
    }
    
    func endpointTextMessageReceived(_ data: [AnyHashable : Any]) {
        eventSink?(["event": "endpointTextMessageReceived", "data": data])
    }
    
    func screenShareToggled(_ data: [AnyHashable : Any]) {
        eventSink?(["event": "screenShareToggled", "data": data])
    }
    
    func chatMessageReceived(_ data: [AnyHashable : Any]) {
        eventSink?(["event": "chatMessageReceived", "data": data])
    }
    
    func chatToggled(_ data: [AnyHashable : Any]) {
        eventSink?(["event": "chatToggled", "data": data])
    }
    
    func participantsInfoRetrieved(_ data: [AnyHashable : Any]) {
        eventSink?(["event": "participantsInfoRetrieved", "data": data])
    }
    
    func customOverflowMenuButtonPressed(_ data: [AnyHashable : Any]) {
        eventSink?(["event": "customOverflowMenuButtonPressed", "data": data])
    }
    
    func ready(toClose data: [AnyHashable : Any]) {
        eventSink?(["event": "readyToClose"])
        DispatchQueue.main.async {
            self.cleanUp()
        }
    }
}
