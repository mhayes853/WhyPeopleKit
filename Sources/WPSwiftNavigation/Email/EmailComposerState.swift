import Foundation

// MARK: - EmailComposerState

public struct EmailComposerState {
  public var subject: String?
  public var toRecipients: [EmailAddress]?
  public var ccRecipients: [EmailAddress]?
  public var bccRecipients: [EmailAddress]?
  public var messageBody: String?
  public var isMessageBodyHTML = false
  public var preferredSendingEmailAddress: EmailAddress?
  public var attachments: [Attachment]?
  
  public init(
    subject: String? = nil,
    toRecipients: [EmailAddress]? = nil,
    ccRecipients: [EmailAddress]? = nil,
    bccRecipients: [EmailAddress]? = nil,
    messageBody: String? = nil,
    isMessageBodyHTML: Bool = false,
    preferredSendingEmailAddress: EmailAddress? = nil,
    attachments: [Attachment]? = nil
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
    attachments: [Attachment]? = nil
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

// MARK: - Attachment

extension EmailComposerState {
  public struct Attachment {
    public var contents: Contents
    public var mimeType: MIMEType
    public var filename: String
    
    public init(data: Data, mimeType: MIMEType, filename: String) {
      self.contents = .data(data)
      self.mimeType = mimeType
      self.filename = filename
    }
    
    public init(url: URL, mimeType: MIMEType, filename: String) {
      self.contents = .url(url)
      self.mimeType = mimeType
      self.filename = filename
    }
  }
}

extension EmailComposerState.Attachment {
  public enum Contents {
    case data(Data)
    case url(URL)
  }
}

extension EmailComposerState.Attachment.Contents {
  public func data() throws -> Data {
    switch self {
    case let .data(data): data
    case let .url(url): try Data(contentsOf: url)
    }
  }
}
