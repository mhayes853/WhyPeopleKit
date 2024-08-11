import SwiftUI
import MessageUI

// MARK: - CanSendEmail

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
  @Entry public var canSendEmail = CanSendEmail()
}

// MARK: - UITraitCollection

extension UITraitCollection {
  @available(iOS 17.0, *)
  public var canSendEmail: CanSendEmail {
    self[CanSendEmailTraitDefinition.self]
  }
}

@available(iOS 17.0, *)
extension UIMutableTraits {
  public var canSendEmail: CanSendEmail {
    get { self[CanSendEmailTraitDefinition.self] }
    set { self[CanSendEmailTraitDefinition.self] = newValue }
  }
}

private struct CanSendEmailTraitDefinition: UITraitDefinition {
  static let defaultValue = CanSendEmail()
}
