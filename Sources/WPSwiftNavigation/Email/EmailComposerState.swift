import Foundation

// MARK: - EmailComposerState

public struct EmailComposerState: Hashable, Sendable {
  public var subject: String?
  public var toRecipients: [EmailAddress]?
  public var ccRecipients: [EmailAddress]?
  public var bccRecipients: [EmailAddress]?
  public var messageBody: String?
  public var isMessageBodyHTML = false
  public var preferredSendingEmailAddress: EmailAddress?
  public var attachments: [EmailComposerAttachment]?
  
  public init(
    subject: String? = nil,
    toRecipients: [EmailAddress]? = nil,
    ccRecipients: [EmailAddress]? = nil,
    bccRecipients: [EmailAddress]? = nil,
    messageBody: String? = nil,
    isMessageBodyHTML: Bool = false,
    preferredSendingEmailAddress: EmailAddress? = nil,
    attachments: [EmailComposerAttachment]? = nil
  ) {
    self.subject = subject
    self.toRecipients = toRecipients
    self.ccRecipients = ccRecipients
    self.bccRecipients = bccRecipients
    self.messageBody = messageBody
    self.isMessageBodyHTML = isMessageBodyHTML
    self.preferredSendingEmailAddress = preferredSendingEmailAddress
    self.attachments = attachments
  }
  
  public init(
    subject: String? = nil,
    toRecipients: [EmailAddress]? = nil,
    ccRecipients: [EmailAddress]? = nil,
    bccRecipients: [EmailAddress]? = nil,
    htmlBody: String? = nil,
    preferredSendingEmailAddress: EmailAddress? = nil,
    attachments: [EmailComposerAttachment]? = nil
  ) {
    self.subject = subject
    self.toRecipients = toRecipients
    self.ccRecipients = ccRecipients
    self.bccRecipients = bccRecipients
    self.messageBody = htmlBody
    self.isMessageBodyHTML = true
    self.preferredSendingEmailAddress = preferredSendingEmailAddress
    self.attachments = attachments
  }
}
