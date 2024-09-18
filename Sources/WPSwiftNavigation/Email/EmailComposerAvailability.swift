import SwiftUI

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
///   @Environment(\.canSendEmail) private var canSendEmail
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
  private let canSendEmail: @MainActor @Sendable () -> Bool

  public init(_ canSendEmail: @MainActor @Sendable @escaping () -> Bool) {
    self.canSendEmail = canSendEmail
  }
}

// MARK: - Default Init

#if canImport(MessageUI)
  extension EmailComposerAvailability {
    public init() {
      self.init { MFMailComposeViewController.canSendMail() }
    }
  }
#else
  extension EmailComposerAvailability {
    @available(watchOS, unavailable)
    @available(macOS, unavailable)
    @available(tvOS, unavailable)
    public init() {
      fatalError()
    }
  }
#endif

// MARK: - Call as Function

extension EmailComposerAvailability {
  @MainActor
  public func callAsFunction() -> Bool {
    self.canSendEmail()
  }
}

// MARK: - Environment Value

#if canImport(MessageUI)
  extension EnvironmentValues {
    /// A value that can be called as a function to determine if the user's device is capable of
    /// sending email through the system mail composer.
    @Entry public var canSendEmail = EmailComposerAvailability()
  }
#else
  extension EnvironmentValues {
    /// A value that can be called as a function to determine if the user's device is capable of
    /// sending email through the system mail composer.
    @available(watchOS, unavailable)
    @available(macOS, unavailable)
    @available(tvOS, unavailable)
    public var canSendEmail: EmailComposerAvailability {
      get { fatalError() }
      set { fatalError() }
    }
  }
#endif

// MARK: - UITraitCollection

#if canImport(MessageUI)
  extension UITraitCollection {
    /// A value that can be called as a function to determine if the user's device is capable of
    /// sending email through the system mail composer.
    @available(iOS 17.0, *)
    public var canSendEmail: EmailComposerAvailability {
      self[CanSendEmailTraitDefinition.self]
    }
  }

  @available(iOS 17.0, *)
  extension UIMutableTraits {
    /// A value that can be called as a function to determine if the user's device is capable of
    /// sending email through the system mail composer.
    public var canSendEmail: EmailComposerAvailability {
      get { self[CanSendEmailTraitDefinition.self] }
      set { self[CanSendEmailTraitDefinition.self] = newValue }
    }
  }

  private struct CanSendEmailTraitDefinition: UITraitDefinition {
    static let defaultValue = EmailComposerAvailability()
  }
#elseif os(tvOS)
  extension UITraitCollection {
    /// A value that can be called as a function to determine if the user's device is capable of
    /// sending email through the system mail composer.
    @available(tvOS, unavailable)
    public var canSendEmail: EmailComposerAvailability {
      fatalError()
    }
  }

  @available(tvOS, unavailable)
  extension UIMutableTraits {
    /// A value that can be called as a function to determine if the user's device is capable of
    /// sending email through the system mail composer.
    public var canSendEmail: EmailComposerAvailability {
      get { fatalError() }
      set { fatalError() }
    }
  }
#endif
