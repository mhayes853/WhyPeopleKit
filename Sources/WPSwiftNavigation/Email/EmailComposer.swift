import SwiftUI
import MessageUI
import SwiftNavigation

// MARK: - MFMailComposeViewController Helpers

extension MFMailComposeViewController {
  public convenience init(state: EmailComposerState) throws {
    self.init(nibName: nil, bundle: nil)
    try self.setState(state)
  }
  
  public func setState(_ state: EmailComposerState) throws {
    if let subject = state.subject {
      self.setSubject(subject)
    }
    if let toRecipients = state.toRecipients {
      self.setToRecipients(toRecipients.map(\.rawValue))
    }
    if let ccRecipients = state.ccRecipients {
      self.setCcRecipients(ccRecipients.map(\.rawValue))
    }
    if let bccRecipients = state.bccRecipients {
      self.setBccRecipients(bccRecipients.map(\.rawValue))
    }
    if let messageBody = state.messageBody {
      self.setMessageBody(messageBody, isHTML: state.isMessageBodyHTML)
    }
    if let preferredSendingEmailAddress = state.preferredSendingEmailAddress {
      self.setPreferredSendingEmailAddress(preferredSendingEmailAddress.rawValue)
    }
    if let attachments = state.attachments {
      for attachment in attachments {
        self.addAttachmentData(
          try attachment.contents.data(),
          mimeType: attachment.mimeType.rawValue,
          fileName: attachment.filename
        )
      }
    }
  }
}

// MARK: - Present

extension UIViewController {
  @discardableResult
  public func present(
    emailComposer: UIBinding<EmailComposerState?>,
    onFinished: ((EmailComposerResult) -> Void)? = nil,
    onDismiss: (() -> Void)? = nil
  ) -> ObservationToken {
    @UIBinding var composerController: EmailComposerController?
    let delegate = EmailComposerDelegate(emailComposer: emailComposer, onFinished: onFinished)
    let observeToken = self.observe { [weak self] in
      guard let self else { return }
      if let state = emailComposer.wrappedValue {
        do {
          let controller = try EmailComposerController(state: state)
          controller.mailComposeDelegate = delegate
          composerController = controller
        } catch {
          onFinished?(.failed(error))
          emailComposer.wrappedValue = nil
          composerController = nil
        }
      } else {
        composerController = nil
      }
    }
    let presentToken = self.present(item: $composerController) {
      onDismiss?()
      emailComposer.wrappedValue = nil
    } content: {
      $0
    }
    let token = ObservationToken {
      observeToken.cancel()
      presentToken.cancel()
    }
    // NB: Prevent the token from being deallocated immediately after being returned.
    objc_setAssociatedObject(self, tokenKey, token, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    return token
  }
}

private nonisolated(unsafe) let tokenKey = malloc(1)!

private final class EmailComposerController: MFMailComposeViewController, Identifiable {
}

private final class EmailComposerDelegate: NSObject, MFMailComposeViewControllerDelegate {
  @UIBinding private var emailComposer: EmailComposerState?
  private let onFinished: ((EmailComposerResult) -> Void)?
  
  init(emailComposer: UIBinding<EmailComposerState?>, onFinished: ((EmailComposerResult) -> Void)?) {
    self._emailComposer = emailComposer
    self.onFinished = onFinished
  }
  
  func mailComposeController(
    _ controller: MFMailComposeViewController,
    didFinishWith result: MFMailComposeResult,
    error: (any Error)?
  ) {
    if let error {
      self.onFinished?(.failed(error))
    } else {
      switch result {
      case .cancelled: self.onFinished?(.cancelled)
      case .saved: self.onFinished?(.saved)
      case .sent: self.onFinished?(.sent)
      case .failed: self.onFinished?(.failed(nil))
      @unknown default: self.onFinished?(.failed(nil))
      }
    }
    self.emailComposer = nil
  }
}
