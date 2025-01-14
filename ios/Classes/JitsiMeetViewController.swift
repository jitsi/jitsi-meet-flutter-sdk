import Flutter
import UIKit
import JitsiMeetSDK

class JitsiMeetViewController: UIViewController {
    fileprivate var pipViewCoordinator: PiPViewCoordinator?
    fileprivate var wrapperJitsiMeetView: UIView?
    var jitsiMeetView: JitsiMeetView?
    
    private lazy var topView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private let bottomImageSize: CGSize = CGSize(width: 250, height: 34)
    
    private lazy var bottomImageView: UIImageView = {
        let view = UIImageView()
        view.frame.size = bottomImageSize
        view.contentMode = .scaleAspectFit
        if let url = Bundle(for: type(of: self)).url(forResource: "bottomSection", withExtension: "png") {
            view.image = UIImage(contentsOfFile: url.path)
        }
        return view
    }()
    
    private lazy var bottomLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 14, weight: .light)
        label.textAlignment = .left
        label.text = "Enter text"
        return label
    }()
    
    private var safeAreaTop: CGFloat { view.safeAreaInsets.top }
    private var safeAreaBottom: CGFloat { view.safeAreaInsets.bottom }
    private let topViewHeight: CGFloat = 50
    private let bottomViewHeight: CGFloat = 50

    let options: JitsiMeetConferenceOptions
    let eventSink: FlutterEventSink

    init(options: JitsiMeetConferenceOptions, eventSink: @escaping FlutterEventSink) {
        self.options = options
        self.eventSink = eventSink
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        openJitsiMeet()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateViewFrames()
    }

    func openJitsiMeet() {
        cleanUp()

        jitsiMeetView = JitsiMeetView()
        let wrapperJitsiMeetView = WrapperView()
        wrapperJitsiMeetView.backgroundColor = .clear
        wrapperJitsiMeetView.frame = view.bounds
        self.wrapperJitsiMeetView = wrapperJitsiMeetView

        wrapperJitsiMeetView.addSubview(topView)
        wrapperJitsiMeetView.addSubview(jitsiMeetView!)
        wrapperJitsiMeetView.addSubview(bottomView)
        
        bottomView.addSubview(bottomImageView)
        bottomView.addSubview(bottomLabel)
        
        let bottomViewGesture = UITapGestureRecognizer(target: self, action: #selector(handleBottomViewTap))
        bottomView.isUserInteractionEnabled = true
        bottomView.addGestureRecognizer(bottomViewGesture)

        jitsiMeetView!.delegate = self
        jitsiMeetView!.join(options)

        pipViewCoordinator = PiPViewCoordinator(withView: wrapperJitsiMeetView)
        pipViewCoordinator?.configureAsStickyView(withParentView: view)
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
    
    private func updateViewFrames() {
        guard let wrapperJitsiMeetView = wrapperJitsiMeetView else { return }
        topView.frame = CGRect(
            x: 0,
            y: 0,
            width: wrapperJitsiMeetView.bounds.width,
            height: topViewHeight + safeAreaTop
        )
        
        jitsiMeetView?.frame = CGRect(
            x: 0,
            y: topViewHeight + safeAreaTop,
            width: wrapperJitsiMeetView.bounds.width,
            height: wrapperJitsiMeetView.bounds.height - topViewHeight - bottomViewHeight - safeAreaTop - safeAreaBottom
        )
        
        bottomView.frame = CGRect(
            x: 0,
            y: wrapperJitsiMeetView.bounds.height - bottomViewHeight - safeAreaBottom,
            width: wrapperJitsiMeetView.bounds.width,
            height: bottomViewHeight + safeAreaBottom
        )
        
        
        let bottomLabelWidth = view.frame.width - 16 - bottomImageSize.width - 16
        bottomLabel.frame = CGRect(
            x: 16,
            y: 8,
            width: bottomLabelWidth,
            height: bottomImageSize.height
        )
        
        bottomImageView.frame = CGRect(
            x: 16 + bottomLabelWidth,
            y: 8,
            width: bottomImageSize.width,
            height: bottomImageSize.height
        )
        
    }
    
    @objc private func handleBottomViewTap() {
        self.eventSink(["event": "bottomViewTapped"])
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

    func customOverflowMenuButtonPressed(_ data: [AnyHashable : Any]) {
        self.eventSink(["event": "customOverflowMenuButtonPressed", "data": data])
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
        }
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
