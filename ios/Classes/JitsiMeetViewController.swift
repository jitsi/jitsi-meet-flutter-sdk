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
        view.image = self.getImage(forResource: "bottomSection", withExtension: "png")
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
    
    private lazy var saveResultStack: UIView = {
        let view = UIView()
        view.frame = CGRect(origin: .zero, size: stacksSize)
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = self.getImage(forResource: "CrossIcon", withExtension: "png")
        imageView.frame = CGRect(
            x: (stacksSize.width / 2) - 12,
            y: 0,
            width: 24,
            height: 24
        )
        
        let label = UILabel()
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 14, weight: .light)
        label.textAlignment = .center
        label.textColor = UIColor(red: 71/255, green: 158/255, blue: 132/255, alpha: 1)
        label.text = "Save results"
        label.frame = CGRect(
            x: 0,
            y: 24,
            width: stacksSize.width,
            height: stacksSize.height - 24
        )
        
        view.addSubview(imageView)
        view.addSubview(label)
        
        return view
    }()
    
    private lazy var changeRoomStack: UIView = {
        let view = UIView()
        view.frame = CGRect(origin: .zero, size: stacksSize)
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = self.getImage(forResource: "ChangeIcon", withExtension: "png")
        imageView.frame = CGRect(
            x: (stacksSize.width / 2) - 12,
            y: 0,
            width: 24,
            height: 24
        )
        
        let label = UILabel()
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 14, weight: .light)
        label.textAlignment = .center
        label.textColor = UIColor(red: 85/255, green: 132/255, blue: 146/255, alpha: 1)
        label.text = "Change room"
        label.frame = CGRect(
            x: 0,
            y: 24,
            width: stacksSize.width,
            height: stacksSize.height - 24
        )
        
        view.addSubview(imageView)
        view.addSubview(label)
        
        return view
    }()
    
    private lazy var getTopicButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(red: 242/255, green: 201/255, blue: 76/255, alpha: 1)
        button.setTitle("Get a topic", for: [])
        button.setTitleColor(.black, for: [])
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        button.layer.cornerRadius = 8
        button.layer.shadowRadius = 2
        button.layer.shadowOpacity = 1
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
        button.addTarget(self, action: #selector(handleGetTopicButtonTap), for: .touchUpInside)
        return button
    }()
    
    private var safeAreaTop: CGFloat { view.safeAreaInsets.top }
    private var safeAreaBottom: CGFloat { view.safeAreaInsets.bottom }
    private let topViewHeight: CGFloat = 58
    private let bottomViewHeight: CGFloat = 50
    private var viewWidth: CGFloat { view.frame.width }
    private let stacksSize = CGSize(width: 90, height: 50)

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
        
        topView.addSubview(getTopicButton)
        topView.addSubview(changeRoomStack)
        topView.addSubview(saveResultStack)
        
        bottomView.addSubview(bottomImageView)
        bottomView.addSubview(bottomLabel)
        
        let changeRoomGesture = UITapGestureRecognizer(target: self, action: #selector(handleChangeRoomViewTap))
        changeRoomStack.addGestureRecognizer(changeRoomGesture)
        
        let saveResultsGesture = UITapGestureRecognizer(target: self, action: #selector(handleSaveResultsViewTap))
        saveResultStack.addGestureRecognizer(saveResultsGesture)
        
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
        
        getTopicButton.frame = CGRect(
            x: 16,
            y: topView.frame.height - stacksSize.height - 5,
            width: viewWidth - 16 - 8 - stacksSize.width - 8 - stacksSize.width - 16,
            height: 40
        )
        
        changeRoomStack.frame = CGRect(
            x: 16 + getTopicButton.frame.width + 8,
            y: topView.frame.height - stacksSize.height - 8,
            width: stacksSize.width,
            height: stacksSize.height
        )
        
        saveResultStack.frame = CGRect(
            x: 16 + getTopicButton.frame.width + 8 + stacksSize.width + 8,
            y: topView.frame.height - stacksSize.height - 8,
            width: stacksSize.width,
            height: stacksSize.height
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
        saveResultStack.layoutIfNeeded()
        changeRoomStack.layoutIfNeeded()
    }
    
    @objc private func handleBottomViewTap() {
        self.eventSink(["event": "bottomViewTapped"])
    }
    
    @objc private func handleChangeRoomViewTap() {
        self.eventSink(["event": "changeRoomTapped"])
    }
    
    @objc private func handleSaveResultsViewTap() {
        self.eventSink(["event": "saveResultsTapped"])
    }
    
    @objc private func handleGetTopicButtonTap() {
        self.eventSink(["event": "getTopicTapped"])
    }
    
    private func getImage(forResource resource: String, withExtension extensionPath: String) -> UIImage? {
        guard let url = Bundle(for: type(of: self)).url(forResource: resource, withExtension: extensionPath) else {
            return nil
        }
        return UIImage(contentsOfFile: url.path)
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
