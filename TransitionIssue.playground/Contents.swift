//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport

class MainViewController: UIViewController {

    private var modalTransitionDelegate: ModalTransitionDelegate?

    override func loadView() {
        let view = UIView()
        view.backgroundColor = .white

        let textField = UITextField(frame: CGRect(x: 10, y: 10, width: 200, height: 40))
        textField.backgroundColor = .red
        view.addSubview(textField)

        let button = UIButton(frame: CGRect(x: 100, y: 100, width: 40, height: 40))
        button.setTitle("ShowModal", for: .application)
        button.backgroundColor = .green
        button.addTarget(self, action: #selector(showModal), for: .touchUpInside)
        view.addSubview(button)

        self.view = view
    }

    @objc func showModal() {
        let modalViewController = ModalViewController()
        modalTransitionDelegate = ModalTransitionDelegate()
        modalTransitionDelegate?.setDissmissal(viewController: modalViewController,
                                               with: modalViewController.view)
        modalViewController.modalPresentationStyle = .overCurrentContext
        modalViewController.transitioningDelegate = modalTransitionDelegate
        present(modalViewController, animated: true, completion: nil)
    }
}

class ModalViewController: UIViewController {
    override func loadView() {
        let view = UIView()
        view.backgroundColor = .lightGray

        let label = UILabel()
        label.frame = CGRect(x: 150, y: 200, width: 200, height: 300)
        label.text = "Hello World!"
        label.textColor = .black

        view.addSubview(label)
        self.view = view
    }
}

// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MainViewController()
