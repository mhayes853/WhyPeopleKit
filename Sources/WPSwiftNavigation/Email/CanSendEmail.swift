import SwiftUI
import MessageUI

// MARK: - CanSendEmail

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
public struct CanSendEmail: Sendable {
  private let canSendEmail: @MainActor @Sendable () -> Bool
  
  public init(_ canSendEmail: @MainActor @Sendable @escaping () -> Bool) {
    self.canSendEmail = canSendEmail
  }
}

// MARK: - Default Init

extension CanSendEmail {
  public init() {
    self.init { MFMailComposeViewController.canSendMail() }
  }
}

// MARK: - Call as Function

extension CanSendEmail {
  @MainActor
  public func callAsFunction() -> Bool {
    self.canSendEmail()
  }
}

// MARK: - Environment Value

extension EnvironmentValues {
  /// A value that can be called as a function to determine if the user's device is capable of
  /// sending email through the system mail composer.
  @Entry public var canSendEmail = CanSendEmail()
}

// MARK: - UITraitCollection

extension UITraitCollection {
  /// A value that can be called as a function to determine if the user's device is capable of
  /// sending email through the system mail composer.
  @available(iOS 17.0, *)
  public var canSendEmail: CanSendEmail {
    self[CanSendEmailTraitDefinition.self]
  }
}

@available(iOS 17.0, *)
extension UIMutableTraits {
  /// A value that can be called as a function to determine if the user's device is capable of
  /// sending email through the system mail composer.
  public var canSendEmail: CanSendEmail {
    get { self[CanSendEmailTraitDefinition.self] }
    set { self[CanSendEmailTraitDefinition.self] = newValue }
  }
}

private struct CanSendEmailTraitDefinition: UITraitDefinition {
  static let defaultValue = CanSendEmail()
}
