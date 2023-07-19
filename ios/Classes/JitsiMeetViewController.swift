import UIKit
import JitsiMeetSDK

class JitsiMeetViewController: UIViewController {
    fileprivate var pipViewCoordinator: PiPViewCoordinator?
    fileprivate var wrapperJitsiMeetView: UIView?
    var jitsiMeetView: JitsiMeetView?
    let options: JitsiMeetConferenceOptions

    init(options: JitsiMeetConferenceOptions) {
        self.options = options;
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let defaultOptions = JitsiMeetConferenceOptions.fromBuilder { (builder) in
            builder.serverURL = URL(string: "https://meet.jit.si")
            builder.setFeatureFlag("welcomepage.enabled", withValue: false)
        }
                
        JitsiMeet.sharedInstance().defaultConferenceOptions = defaultOptions
        openJitsiMeet();
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
        pipViewCoordinator?.configureAsStickyView(withParentView: view)

        wrapperJitsiMeetView.alpha = 0
        pipViewCoordinator?.show()
    }

    fileprivate func cleanUp() {
        wrapperJitsiMeetView?.removeFromSuperview()
        wrapperJitsiMeetView = nil
        pipViewCoordinator = nil
        jitsiMeetView = nil
    }
}

extension JitsiMeetViewController: JitsiMeetViewDelegate {
    func conferenceTerminated(_ data: [AnyHashable : Any]!) {
        DispatchQueue.main.async {
            self.pipViewCoordinator?.hide() { _ in
                self.cleanUp()
            }
        }
    }

    func enterPicture(inPicture data: [AnyHashable : Any]!) {
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
