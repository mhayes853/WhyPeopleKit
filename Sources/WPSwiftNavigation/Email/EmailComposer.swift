import SwiftNavigation
import SwiftUI
import UIKitNavigation

#if canImport(MessageUI)
  import MessageUI
#endif

// MARK: - SwiftUI View Modifier

#if canImport(MessageUI)
  extension View {
    /// Presents an email composer based on ``EmailComposerState``.
    ///
    /// Before calling this modifier, make sure to use `@Environment(\.canPresentEmailComposer)` to check if the
    /// user's device is capable of sending email through the system email composer.
    ///
    /// You can pass a callback closure to this modifier that listens for an ``EmailComposerResult``
    /// detailing the result of the composition session.
    ///
    /// ```swift
    /// struct EmailView: View {
    ///   @Environment(\.canPresentEmailComposer) private var canSendEmail
    ///   @State private var state: EmailComposerState?
    ///
    ///   var body: some View {
    ///     Group {
    ///       if self.canSendEmail() {
    ///         Button("Send Email") {
    ///           self.state = EmailComposerState(subject: "My cool email!")
    ///         }
    ///       } else {
    ///         Link(
    ///           "Reach out to us on our support page!",
    ///           destination: URL(string: "https://www.example.com/support")!
    ///         )
    ///       }
    ///     }
    ///     .emailComposer(self.$state) { result in
    ///       switch result {
    ///       case .sent:
    ///         // ...
    ///       case .saved:
    ///         // ...
    ///       case .cancelled:
    ///         // ...
    ///       case let .failed(error):
    ///         // ...
    ///       }
    ///     }
    ///   }
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - state: An ``EmailComposerState``.
    ///   - onFinished: An optional callback closure to handle the result of the composition.
    ///   - onDismiss: The closure to execute when dismissing the email composer.
    /// - Returns: Some view.
    public func emailComposer(
      _ state: Binding<EmailComposerState?>,
      onFinished: ((EmailComposerResult) -> Void)? = nil,
      onDismiss: (() -> Void)? = nil
    ) -> some View {
      self.modifier(
        EmailComposerModifier(state: state, onFinished: onFinished, onDismiss: onDismiss)
      )
    }
  }
#else
  extension View {
    /// Presents an email composer based on ``EmailComposerState``.
    ///
    /// Before calling this modifier, make sure to use `@Environment(\.canPresentEmailComposer)` to check if the
    /// user's device is capable of sending email through the system email composer.
    ///
    /// You can pass a callback closure to this modifier that listens for an ``EmailComposerResult``
    /// detailing the result of the composition session.
    ///
    /// ```swift
    /// struct EmailView: View {
    ///   @Environment(\.canPresentEmailComposer) private var canSendEmail
    ///   @State private var state: EmailComposerState?
    ///
    ///   var body: some View {
    ///     Group {
    ///       if self.canSendEmail() {
    ///         Button("Send Email") {
    ///           self.state = EmailComposerState(subject: "My cool email!")
    ///         }
    ///       } else {
    ///         Link(
    ///           "Reach out to us on our support page!",
    ///           destination: URL(string: "https://www.example.com/support")!
    ///         )
    ///       }
    ///     }
    ///     .emailComposer(self.$state) { result in
    ///       switch result {
    ///       case .sent:
    ///         // ...
    ///       case .saved:
    ///         // ...
    ///       case .cancelled:
    ///         // ...
    ///       case let .failed(error):
    ///         // ...
    ///       }
    ///     }
    ///   }
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - state: An ``EmailComposerState``.
    ///   - onFinished: An optional callback closure to handle the result of the composition.
    ///   - onDismiss: The closure to execute when dismissing the email composer.
    /// - Returns: Some view.
    @available(watchOS, unavailable)
    @available(macOS, unavailable)
    @available(tvOS, unavailable)
    public func emailComposer(
      _ state: Binding<EmailComposerState?>,
      onFinished: ((EmailComposerResult) -> Void)? = nil,
      onDismiss: (() -> Void)? = nil
    ) -> some View {
      fatalError()
    }
  }
#endif

#if canImport(MessageUI)
  private struct EmailComposerModifier: ViewModifier {
    @Binding var state: EmailComposerState?
    let onFinished: ((EmailComposerResult) -> Void)?
    let onDismiss: (() -> Void)?

    @State private var model = Model()

    func body(content: Content) -> some View {
      EmptyView()
//      content.bind(self.$state, to: self.$model.state)
//        .onAppear {
//          @UIBindable var model = self.model
//          UIApplication.shared.topMostViewController?
//            .present(
//              emailComposer: $model.state,
//              onFinished: self.onFinished,
//              onDismiss: self.onDismiss
//            )
//        }
    }
  }

  @Perceptible
  private final class Model {
    var state: EmailComposerState?
  }

  // MARK: - UIViewController Present

  extension UIViewController {
    /// Presents an email composer based on ``EmailComposerState``.
    ///
    /// Before calling this method, make sure to use ``UIKit/UITraitCollection/canPresentEmailComposer`` to
    /// check if the user's device is capable of sending email through the system email composer.
    ///
    /// You can pass a callback closure to this modifier that method for an ``EmailComposerResult``
    /// detailing the result of the composition session.
    ///
    /// ```swift
    /// final class EmailController: UIViewController {
    ///   @UIBinding private var state: EmailComposerState?
    ///
    ///   override func viewDidLoad() {
    ///     super.viewDidLoad()
    ///     if self.traitCollection.canPresentEmailComposer() {
    ///       self.present(emailComposer: self.$state) { result in
    ///         switch result {
    ///         case .sent:
    ///           // ...
    ///         case .saved:
    ///           // ...
    ///         case .cancelled:
    ///           // ...
    ///         case let .failed(error):
    ///           // ...
    ///         }
    ///       }
    ///     }
    ///   }
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - emailComposer: An ``EmailComposerState``.
    ///   - onFinished: An optional callback closure to handle the result of the composition.
    ///   - onDismiss: The closure to execute when dismissing the email composer.
    /// - Returns: An `ObservationToken`.
    @discardableResult
    public func present(
      emailComposer: UIBinding<EmailComposerState?>,
      onFinished: ((EmailComposerResult) -> Void)? = nil,
      onDismiss: (() -> Void)? = nil
    ) -> ObserveToken {
      @UIBinding var composerController: EmailComposerController?
      let delegate = EmailComposerDelegate(emailComposer: emailComposer, onFinished: onFinished)
      let observeToken = self.observe {
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
      let token = ObserveToken {
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

    init(
      emailComposer: UIBinding<EmailComposerState?>,
      onFinished: ((EmailComposerResult) -> Void)?
    ) {
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
#elseif os(tvOS)
  extension UIViewController {
    /// Presents an email composer based on ``EmailComposerState``.
    ///
    /// Before calling this method, make sure to use ``UIKit/UITraitCollection/canPresentEmailComposer`` to
    /// check if the user's device is capable of sending email through the system email composer.
    ///
    /// You can pass a callback closure to this modifier that method for an ``EmailComposerResult``
    /// detailing the result of the composition session.
    ///
    /// ```swift
    /// final class EmailController: UIViewController {
    ///   @UIBinding private var state: EmailComposerState?
    ///
    ///   override func viewDidLoad() {
    ///     super.viewDidLoad()
    ///     if self.traitCollection.canPresentEmailComposer() {
    ///       self.present(emailComposer: self.$state) { result in
    ///         switch result {
    ///         case .sent:
    ///           // ...
    ///         case .saved:
    ///           // ...
    ///         case .cancelled:
    ///           // ...
    ///         case let .failed(error):
    ///           // ...
    ///         }
    ///       }
    ///     }
    ///   }
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - emailComposer: An ``EmailComposerState``.
    ///   - onFinished: An optional callback closure to handle the result of the composition.
    ///   - onDismiss: The closure to execute when dismissing the email composer.
    /// - Returns: An `ObservationToken`.
    @discardableResult
    @available(tvOS, unavailable)
    public func present(
      emailComposer: UIBinding<EmailComposerState?>,
      onFinished: ((EmailComposerResult) -> Void)? = nil,
      onDismiss: (() -> Void)? = nil
    ) -> ObserveToken {
      fatalError()
    }
  }
#endif

// MARK: - MFMailComposeViewController Helpers

#if canImport(MessageUI)
  extension MFMailComposeViewController {
    /// A convenience initializer to create a mail compose controller from an ``EmailComposerState``.
    ///
    /// - Parameter state: An ``EmailComposerState``.
    /// - Throws: If loading the attachment data from a `URL` fails.
    public convenience init(state: EmailComposerState) throws {
      self.init(nibName: nil, bundle: nil)
      try self.setState(state)
    }

    /// Sets the contents of this controller to the specified ``EmailComposerState``
    ///
    /// - Parameter state: An ``EmailComposerState``.
    /// - Throws: If loading the attachment data from a `URL` fails.
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
#endif
