#if canImport(SwiftUI)
  import SwiftUI
#endif

#if canImport(MessageUI)
  import MessageUI
#endif

// MARK: - EmailComposerAvailability

/// A value that can be called as a function to determine if the user's device is capable of
/// sending email through the system mail composer.
///
/// You can obtain an instance of this type in the SwiftUI `EnvironmentValues` and UIKit
/// `UITraitCollection`, and use it to display a different UI based on the return value of
/// ``callAsFunction()``.
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
///     .emailComposer(self.$state)
///   }
/// }
/// ```
public struct EmailComposerAvailability: Sendable {
  private let canPresentEmailComposer: @MainActor @Sendable () -> Bool

  public init(_ canPresentEmailComposer: @MainActor @Sendable @escaping () -> Bool) {
    self.canPresentEmailComposer = canPresentEmailComposer
  }
}

// MARK: - Default Init

#if canImport(SwiftUI)
  #if canImport(MessageUI)
    extension EmailComposerAvailability {
      /// Availability that uses the MessageUI framework to check if the current device can send
      /// email.
      public static var messageUI: Self {
        Self { MFMailComposeViewController.canSendMail() }
      }
    }
  #else
    extension EmailComposerAvailability {
      /// Availability that uses the MessageUI framework to check if the current device can send
      /// email.
      @available(watchOS, unavailable)
      @available(macOS, unavailable)
      @available(tvOS, unavailable)
      public static var messageUI: Self {
        fatalError()
      }
    }
  #endif
#endif

// MARK: - Call as Function

extension EmailComposerAvailability {
  @MainActor
  public func callAsFunction() -> Bool {
    self.canPresentEmailComposer()
  }
}

// MARK: - Environment Value

#if canImport(SwiftUI)
  #if canImport(MessageUI)
    extension EnvironmentValues {
      /// A value that can be called as a function to determine if the user's device is capable of
      /// sending email through the system mail composer.
      @Entry public var canPresentEmailComposer = EmailComposerAvailability.messageUI
    }
  #else
    extension EnvironmentValues {
      /// A value that can be called as a function to determine if the user's device is capable of
      /// sending email through the system mail composer.
      @Entry public var canPresentEmailComposer = EmailComposerAvailability { false }
    }
  #endif

  // MARK: - UITraitCollection

  #if canImport(MessageUI)
    extension UITraitCollection {
      /// A value that can be called as a function to determine if the user's device is capable of
      /// sending email through the system mail composer.
      @available(iOS 17.0, tvOS 17.0, *)
      public var canPresentEmailComposer: EmailComposerAvailability {
        self[CanSendEmailTraitDefinition.self]
      }
    }

    @available(iOS 17.0, tvOS 17.0, *)
    extension UIMutableTraits {
      /// A value that can be called as a function to determine if the user's device is capable of
      /// sending email through the system mail composer.
      public var canPresentEmailComposer: EmailComposerAvailability {
        get { self[CanSendEmailTraitDefinition.self] }
        set { self[CanSendEmailTraitDefinition.self] = newValue }
      }
    }

    #if os(tvOS)
      private struct CanSendEmailTraitDefinition: UITraitDefinition {
        static let defaultValue = EmailComposerAvailability { false }
      }
    #else
      private struct CanSendEmailTraitDefinition: UITraitDefinition {
        static let defaultValue = EmailComposerAvailability.messageUI
      }
    #endif
  #endif
#endif
