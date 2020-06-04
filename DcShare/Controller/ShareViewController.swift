import UIKit
import Social
import DcCore
import MobileCoreServices


class ShareViewController: SLComposeServiceViewController {

    class SimpleLogger: Logger {
        func verbose(_ message: String) {
            print("ShareViewController", "verbose", message)
        }

        func debug(_ message: String) {
            print("ShareViewController", "debug", message)
        }

        func info(_ message: String) {
            print("ShareViewController", "info", message)
        }

        func warning(_ message: String) {
            print("ShareViewController", "warning", message)
        }

        func error(_ message: String) {
            print("ShareViewController", "error", message)
        }
    }

    let logger = SimpleLogger()
    let dcContext = DcContext.shared
    var selectedChatId: Int?
    var selectedChat: DcChat?
    let dbHelper = DatabaseHelper()
    var shareAttachment: ShareAttachment?

    lazy var preview: UIImageView? = {
        let imageView = UIImageView(frame: .zero)
        imageView.clipsToBounds = true
        imageView.shouldGroupAccessibilityChildren = true
        imageView.isAccessibilityElement = false
        return imageView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        // workaround for iOS13 bug
        if #available(iOS 13.0, *) {
            _ = NotificationCenter.default.addObserver(forName: UIResponder.keyboardDidShowNotification, object: nil, queue: .main) { (_) in
                if let layoutContainerView = self.view.subviews.last {
                    layoutContainerView.frame.size.height += 10
                }
            }
        }
        placeholder = String.localized("chat_input_placeholder")

        DispatchQueue.global(qos: .background).async {
            self.shareAttachment = ShareAttachment(dcContext: self.dcContext, inputItems: self.extensionContext?.inputItems, delegate: self)
        }
    }

    override func presentationAnimationDidFinish() {
        if dbHelper.currentDatabaseLocation == dbHelper.sharedDbFile {
            dcContext.logger = self.logger
            dcContext.openDatabase(dbFile: dbHelper.sharedDbFile)
            if dcContext.isConfigured() {
                selectedChatId = dcContext.getChatIdByContactId(contactId: Int(DC_CONTACT_ID_SELF))
                if let chatId = selectedChatId {
                    selectedChat = dcContext.getChat(chatId: chatId)
                }
                reloadConfigurationItems()
            } else {
                let errorViewController = ErrorViewController(delegate: self)
                self.pushConfigurationViewController(errorViewController)
            }
        } else {
            cancel()
        }
    }

    override func loadPreviewView() -> UIView! {
        return preview
    }

    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return  !(contentText?.isEmpty ?? true) || !(self.shareAttachment?.isEmpty ?? true)
    }

    private func setupNavigationBar() {
        guard let item = navigationController?.navigationBar.items?.first else { return }
        let button = UIBarButtonItem(
            title: String.localized("menu_send"),
            style: .done,
            target: self,
            action: #selector(appendPostTapped))
        item.rightBarButtonItem? = button
    }

    /// Invoked when the user wants to post.
    @objc
    private func appendPostTapped() {
        if let chatId = self.selectedChatId {
            guard var messages = shareAttachment?.messages else { return }
            if !self.contentText.isEmpty {
                if messages.count == 1 {
                    messages[0].text?.append(self.contentText)
                } else {
                    let message = DcMsg(viewType: DC_MSG_TEXT)
                    message.text = self.contentText
                    messages.insert(message, at: 0)
                }
            }
            let chatListController = SendingController(chatId: chatId, dcMsgs: messages, dcContext: dcContext)
            chatListController.delegate = self
            self.pushConfigurationViewController(chatListController)
        }
    }

    func quit() {
        if dbHelper.currentDatabaseLocation == dbHelper.sharedDbFile {
            dcContext.closeDatabase()
        }

        // Inform the host that we're done, so it un-blocks its UI.
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }

    override func configurationItems() -> [Any]! {
        logger.debug("configurationItems")
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.

        let item = SLComposeSheetConfigurationItem()
        item?.title = String.localized("forward_to")
        item?.value = selectedChat?.name
        logger.debug("configurationItems chat name: \(String(describing: selectedChat?.name))")
        item?.tapHandler = {
            let chatListController = ChatListController(dcContext: self.dcContext, chatListDelegate: self)
            self.pushConfigurationViewController(chatListController)
        }

        return [item as Any]
    }

    override func didSelectCancel() {
        quit()
    }

    func popControllerAndClose() {
        DispatchQueue.main.async {
            self.popConfigurationViewController()
            self.quit()
        }
    }
}

extension ShareViewController: ErrorViewControllerDelegate {
    func onCancelPressed() {
        popControllerAndClose()
    }
}

extension ShareViewController: ChatListDelegate {
    func onChatSelected(chatId: Int) {
        selectedChatId = chatId
        selectedChat = dcContext.getChat(chatId: chatId)
        reloadConfigurationItems()
        popConfigurationViewController()
    }
}

extension ShareViewController: SendingControllerDelegate {
    func onSendingAttemptFinished() {
        popControllerAndClose()
    }
}

extension ShareViewController: ShareAttachmentDelegate {
    func onUrlShared(url: URL) {
        DispatchQueue.main.async {
            if var contentText = self.contentText, !contentText.isEmpty {
                contentText.append("\n\(url.absoluteString)")
                self.textView.text = contentText
            } else {
                self.textView.text = "\(url.absoluteString)"
            }
        }
    }

    func onAttachmentChanged() {
        DispatchQueue.main.async {
            self.validateContent()
        }
    }

    func onThumbnailChanged() {
        DispatchQueue.main.async {
            if let preview = self.preview {
                preview.image = self.shareAttachment?.thumbnail ?? nil
            }
        }
    }
}
