import Flutter
import UIKit
import JitsiMeetSDK

class JitsiMeetViewController: UIViewController {
    fileprivate var pipViewCoordinator: PiPViewCoordinator?
    fileprivate var wrapperJitsiMeetView: UIView?
    var jitsiMeetView: JitsiMeetView?

    let options: JitsiMeetConferenceOptions
    let eventSink: FlutterEventSink

    // Host app's status bar style, restored when the Jitsi UI leaves the screen.
    fileprivate var hostStatusBarStyle: UIStatusBarStyle?
    fileprivate var isInPiP = false

    init(options: JitsiMeetConferenceOptions, eventSink: @escaping FlutterEventSink) {
        self.options = options;
        self.eventSink = eventSink;
        super.init(nibName: nil, bundle: nil)
        // overFullScreen does not take over the status bar unless asked to.
        modalPresentationCapturesStatusBarAppearance = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    // Used by hosts with view controller-based status bar appearance.
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if isInPiP {
            return presentingViewController?.preferredStatusBarStyle ?? .default
        }
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        openJitsiMeet();
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applyLightStatusBar()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        restoreHostStatusBar()
    }

    // Global setter is a no-op for view controller-based hosts; needed for Flutter's default (NO).
    fileprivate func applyLightStatusBar() {
        if hostStatusBarStyle == nil {
            hostStatusBarStyle = UIApplication.shared.statusBarStyle
        }
        UIApplication.shared.statusBarStyle = .lightContent
        setNeedsStatusBarAppearanceUpdate()
    }

    fileprivate func restoreHostStatusBar() {
        if let style = hostStatusBarStyle {
            UIApplication.shared.statusBarStyle = style
            hostStatusBarStyle = nil
        }
        setNeedsStatusBarAppearanceUpdate()
    }

    func openJitsiMeet() {
        cleanUp()

        jitsiMeetView = JitsiMeetView()
        let wrapperJitsiMeetView = WrapperView()
        wrapperJitsiMeetView.backgroundColor = .black
        self.wrapperJitsiMeetView = wrapperJitsiMeetView

        wrapperJitsiMeetView.addSubview(jitsiMeetView!)

        jitsiMeetView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        jitsiMeetView!.delegate = self
        jitsiMeetView!.join(options)

        pipViewCoordinator = PiPViewCoordinator(withView: wrapperJitsiMeetView)
        pipViewCoordinator?.delegate = self
        pipViewCoordinator?.configureAsStickyView(withParentView: view)

        wrapperJitsiMeetView.alpha = 0
        pipViewCoordinator?.show()
    }

    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        let rect = CGRect(origin: CGPoint.zero, size: size)
        pipViewCoordinator?.resetBounds(bounds: rect)
    }

    fileprivate func cleanUp() {
        jitsiMeetView?.removeFromSuperview()
        wrapperJitsiMeetView?.removeFromSuperview()
        jitsiMeetView = nil
        wrapperJitsiMeetView = nil
        pipViewCoordinator = nil
    }
}

extension JitsiMeetViewController: JitsiMeetViewDelegate {
    func conferenceJoined(_ data: [AnyHashable : Any]) {
        self.eventSink(["event": "conferenceJoined", "data": data])
    }

    func conferenceTerminated(_ data: [AnyHashable: Any]) {
        self.eventSink(["event": "conferenceTerminated", "data": data])
    }

    func conferenceWillJoin(_ data: [AnyHashable : Any]) {
        self.eventSink(["event": "conferenceWillJoin", "data": data])
    }

    func participantJoined(_ data: [AnyHashable : Any]) {
        self.eventSink(["event": "participantJoined", "data": data])
    }

    func participantLeft(_ data: [AnyHashable : Any]) {
        self.eventSink(["event": "participantLeft", "data": data])
    }

    func audioMutedChanged(_ data: [AnyHashable : Any]) {
        self.eventSink(["event": "audioMutedChanged", "data": data])
    }

    func videoMutedChanged(_ data: [AnyHashable : Any]) {
        self.eventSink(["event": "videoMutedChanged", "data": data])
    }

    func endpointTextMessageReceived(_ data: [AnyHashable : Any]) {
        self.eventSink(["event": "endpointTextMessageReceived", "data": data])
    }

    func screenShareToggled(_ data: [AnyHashable : Any]) {
        self.eventSink(["event": "screenShareToggled", "data": data])
    }

    func chatMessageReceived(_ data: [AnyHashable : Any]) {
        self.eventSink(["event": "chatMessageReceived", "data": data])
    }

    func chatToggled(_ data: [AnyHashable : Any]) {
        self.eventSink(["event": "chatToggled", "data": data])
    }

    func participantsInfoRetrieved(_ data: [AnyHashable : Any]) {
        self.eventSink(["event": "participantsInfoRetrieved", "data": data])
    }

    func customButtonPressed(_ data: [AnyHashable : Any]) {
        self.eventSink(["event": "customButtonPressed", "data": data])
    }

    func ready(toClose data: [AnyHashable : Any]) {
        self.eventSink(["event": "readyToClose"])
        DispatchQueue.main.async {
            self.pipViewCoordinator?.hide { _ in
                self.cleanUp()
                self.dismiss(animated: true, completion: nil)
            }
        }
    }

    func enterPicture(inPicture data: [AnyHashable: Any]) {
        DispatchQueue.main.async {
            self.pipViewCoordinator?.enterPictureInPicture()
            // Host UI is visible around the PiP window, so give it back its style.
            self.isInPiP = true
            self.restoreHostStatusBar()
        }
    }
}

extension JitsiMeetViewController: PiPViewCoordinatorDelegate {
    func exitPictureInPicture() {
        isInPiP = false
        applyLightStatusBar()
    }
}

class WrapperView: UIView {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
}
