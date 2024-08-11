import SwiftUI
import MessageUI

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
