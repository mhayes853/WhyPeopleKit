import WPFoundation

// MARK: - EmailComposerState

/// A data type that describes an email composition that is presented to the user.
///
/// This type can be used in your application's state in order to control the presentation of email
/// compositions. This API can be used to push the logic of email composer presentations into
/// your model, making it easier to test, and simplifying your view layer.
///
/// To use this API, you can first create an instance of this type inside an observable model:
///
/// ```swift
/// @Observable
/// final class HelpAndSupportModel {
///   var emailComposer: EmailComposerState?
///
///   func bugReported() {
///     self.emailComposer = EmailComposerState(
///       subject: "I found a bug!",
///       toRecipients: [.supportEmail],
///       messageBody: "Please describe the bug."
///     )
///   }
/// }
/// ```
///
/// Then, in your view, you can use the ``SwiftUICore/View/emailComposer(_:onFinished:onDismiss:)``
/// modifier to present the email composer. However, make sure to check if the composer is
/// available on the user's device using `@Environment(\.canSendEmail)`.
///
/// ```swift
/// struct EmailView: View {
///   @Environment(\.canSendEmail) private var canSendEmail
///   @State private var model = HelpAndSupportModel()
///
///   var body: some View {
///     Group {
///       if self.canSendEmail() {
///         Button("Report Bug") {
///           self.model.bugReported()
///         }
///       } else {
///         Link(
///           "Reach out to us on our support page!",
///           destination: URL(string: "https://www.example.com/support")!
///         )
///       }
///     }
///     .emailComposer(self.$model.emailComposer)
///   }
/// }
/// ```
///
/// With this, your observable model controls the presentation and dismissal of the email composer.
///
/// Furthermore, you can handle the result of the composition in your model using
/// ``EmailComposerResult``.
///
/// ```swift
/// @Observable
/// final class HelpAndSupportModel {
///   // ...
///   func bugReportFinished(result: EmailComposerResult) {
///     switch result {
///     case .sent:
///       // ...
///     case .saved:
///       // ...
///     case .cancelled:
///       // ...
///     case let .failed(error):
///       // ...
///     }
///   }
/// }
/// ```
///
/// Then, you can use the callback on the email composer view modifier to send the result to your
/// model.
///
/// ```swift
/// struct EmailView: View {
///   @Environment(\.canSendEmail) private var canSendEmail
///   @State private var model = HelpAndSupportModel()
///
///   var body: some View {
///     Group {
///       if self.canSendEmail() {
///         Button("Report Bug") {
///           self.model.bugReported()
///         }
///       } else {
///         Link(
///           "Reach out to us on our support page!",
///           destination: URL(string: "https://www.example.com/support")!
///         )
///       }
///     }
///     .emailComposer(self.$model.emailComposer) {
///       self.model.reportBugFinished($0)
///     }
///   }
/// }
/// ```
///
/// Since this data type is just a simple Hashable struct, it makes it easy to test.
///
/// ```swift
/// @Test("Bug Reporting Flow")
/// func bugReporting() {
///   let model = HelpAndSupportModel()
///   #expect(model.emailComposer == nil)
///
///   model.bugReported()
///   let expectedState = EmailComposerState(
///     subject: "I found a bug!",
///     toRecipients: [.supportEmail],
///     messageBody: "Please describe the bug."
///   )
///   #expect(model.emailComposer == expectedState)
///
///   model.bugReportFinished(result: .sent)
///   // Assert on logic after the bug report finished...
/// }
/// ```
public struct EmailComposerState: Hashable, Sendable {
  public var subject: String?
  public var toRecipients: [EmailAddress]?
  public var ccRecipients: [EmailAddress]?
  public var bccRecipients: [EmailAddress]?
  public var messageBody: String?
  public var isMessageBodyHTML = false
  public var preferredSendingEmailAddress: EmailAddress?
  public var attachments: [EmailComposerAttachment]?
  
  /// Creates an email composer state.
  ///
  /// - Parameters:
  ///   - subject: The subject of the email.
  ///   - toRecipients: A list of recipients.
  ///   - ccRecipients: A list of cc recipients.
  ///   - bccRecipients: A list of bcc recipients.
  ///   - messageBody: The body of the email.
  ///   - isMessageBodyHTML: Whether or not the body is HTML.
  ///   - preferredSendingEmailAddress: The user's preferred email address to use in the from field.
  ///   - attachments: A list of attachments.
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
  
  /// Creates an email composer state with an HTML body.
  ///
  /// - Parameters:
  ///   - subject: The subject of the email.
  ///   - toRecipients: A list of recipients.
  ///   - ccRecipients: A list of cc recipients.
  ///   - bccRecipients: A list of bcc recipients.
  ///   - htmlBody: The body of the email in HTML.
  ///   - preferredSendingEmailAddress: The user's preferred email address to use in the from field.
  ///   - attachments: A list of attachments.
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
