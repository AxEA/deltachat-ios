import Foundation
import UIKit
import DcCore

protocol ErrorViewControllerDelegate: class {
    func onCancelPressed()
}

class ErrorViewController: UIViewController {
    weak var delegate: ErrorViewControllerDelegate?

    private lazy var errorLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.text = String.localized("share_error_no_account")
        view.numberOfLines = 0
        view.textAlignment = .center
        return view
    }()

    init(delegate: ErrorViewControllerDelegate) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        view.backgroundColor = DcColors.defaultBackgroundColor
        view.addSubview(errorLabel)
        view.addConstraints([errorLabel.constraintCenterXTo(view),
                             errorLabel.constraintCenterYTo(view),
                             errorLabel.constraintAlignLeadingTo(view, paddingLeading: 50),
                             errorLabel.constraintAlignTrailingTo(view, paddingTrailing: 50)
        ])
        self.navigationItem.leftBarButtonItem = UIBarButtonItem()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: String.localized("cancel"),
                                                                 style: UIBarButtonItem.Style.done,
                                                                 target: nil,
                                                                 action: #selector(cancelPressed))
    }

    @objc
    func cancelPressed() {
        delegate?.onCancelPressed()
    }
    
}
