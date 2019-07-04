import UIKit

public final class ModalTransitionDelegate: UIPercentDrivenInteractiveTransition {

    private var dissmissalController: UIViewController?
    private var dissmissalView: UIView?
    private var closeGestureRecognizer: UIPanGestureRecognizer!

    public var isPresentation: Bool = false
    public var isInteractiveDissmalTransition: Bool = false

    public override init() {
        super.init()
        completionCurve = .linear
        closeGestureRecognizer = UIPanGestureRecognizer(target: self,
                                                        action: #selector(dismissalPanGesture(_:)))
    }

    public override func cancel() {
        completionSpeed = 0.5
        super.cancel()
    }

    public override func finish() {
        completionSpeed = 1.0 - 0.5
        super.finish()
    }

    public func setDissmissal(viewController: UIViewController, with view: UIView) {
        dissmissalController = viewController
        dissmissalView = view
        dissmissalView?.addGestureRecognizer(closeGestureRecognizer)
    }
}

extension ModalTransitionDelegate {
    @objc
    private func dismissalPanGesture(_ recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            isInteractiveDissmalTransition = true
            panGestureBegan(recognizer)
        case .changed:
            isInteractiveDissmalTransition = true
            panGestureChanged(recognizer)
        case .cancelled, .ended:
            isInteractiveDissmalTransition = false
            panGestureCancelledAndEnded(recognizer)
        default:
            break
        }
    }

    private func panGestureBegan(_ recognizer: UIPanGestureRecognizer) {
        dissmissalController?.dismiss(animated: true, completion: nil)
    }

    private func panGestureChanged(_ recognizer: UIPanGestureRecognizer) {
        guard let dismissPanGestureView = dissmissalView else {
            return
        }

        let transition = recognizer.translation(in: dissmissalView)
        let size = dismissPanGestureView.bounds.size
        let progress = transition.y / size.height
        update(progress)
    }

    private func panGestureCancelledAndEnded(_ recognizer: UIPanGestureRecognizer) {
        percentComplete > 0.5 ? finish() : cancel()
    }
}

extension ModalTransitionDelegate: UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresentation = true
        return self
    }

    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresentation = false
        return self
    }

    public func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return nil
    }

    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return isInteractiveDissmalTransition ? self : nil
    }
}

extension ModalTransitionDelegate: UIViewControllerAnimatedTransitioning {
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }

    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if isPresentation {
            presentAnimation(using: transitionContext)
        } else {
            dissmissAnimation(using: transitionContext)
        }
    }

    private func presentAnimation(using transitionContext: UIViewControllerContextTransitioning) {

        // Get toViewController and fromViewController
        guard let toViewController = transitionContext.viewController(forKey: .to),
            let fromViewController = transitionContext.viewController(forKey: .from) else {
                return
        }

        // Insert his view into container view
        let containerView = transitionContext.containerView
        if toViewController.isBeingPresented {
            containerView.addSubview(toViewController.view)
        }

        // Calculate inital and final frames
        let finalFrame = transitionContext.finalFrame(for: toViewController)
        let initialFrame = finalFrame.applying(.init(translationX: 0, y: finalFrame.size.height))

        // Apply initial frame to view
        toViewController.view.frame = initialFrame

        // Animate it
//        let duration = transitionDuration(using: transitionContext)
//        UIView.animate(withDuration: duration,
//                       delay: 0.0,
//                       usingSpringWithDamping: 0.8,
//                       initialSpringVelocity: 0.5,
//                       options: [.allowUserInteraction, .curveLinear],
//                       animations: {
//
//                        // Appear
//                        toViewController.view.alpha = 1.0
//                        toViewController.view.frame = finalFrame
//
//        }, completion: { (_) in
//            if !self.isPresentation && !transitionContext.transitionWasCancelled {
//                fromViewController.view.removeFromSuperview()
//            }
//            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
//        })

        let duration = transitionDuration(using: transitionContext)
        UIView.animate(withDuration: duration,
                       animations: {

                        // Disappear
                        toViewController.view.alpha = 1.0
                        toViewController.view.frame = finalFrame

        }, completion: { (_) in
            if !self.isPresentation && !transitionContext.transitionWasCancelled {
                fromViewController.view.removeFromSuperview()
            }
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }

    private func dissmissAnimation(using transitionContext: UIViewControllerContextTransitioning) {

        // Get toViewController and fromViewController
        guard let toViewController = transitionContext.viewController(forKey: .to),
            let fromViewController = transitionContext.viewController(forKey: .from) else {
                return
        }

        // Insert his view into container view
        let containerView = transitionContext.containerView
        if toViewController.isBeingPresented {
            containerView.addSubview(toViewController.view)
        }

        // Calculate inital and final frames
        let initialFrame = transitionContext.finalFrame(for: fromViewController)
        let finalFrame = initialFrame.applying(.init(translationX: 0, y: initialFrame.size.height))

        // Apply initial frame to view
        fromViewController.view.frame = initialFrame

        // Animate it
        let duration = transitionDuration(using: transitionContext)
        UIView.animate(withDuration: duration,
                       animations: {

                        // Disappear
                        fromViewController.view.alpha = 0.5
                        fromViewController.view.frame = finalFrame

        }, completion: { (_) in
            if !self.isPresentation && !transitionContext.transitionWasCancelled {
                fromViewController.view.removeFromSuperview()
            }
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}
