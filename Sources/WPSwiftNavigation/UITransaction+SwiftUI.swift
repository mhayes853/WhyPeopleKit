#if canImport(SwiftUI)
  import SwiftNavigation
  import SwiftUI

  extension UITransaction {
    /// Creates a transaction and assigns its animation property.
    ///
    /// - Parameter animation: The animation to perform when the current state changes.
    public init(animation: Animation? = nil) {
      self.init()
      self.swiftUI.animation = animation
    }

    /// SwiftUI-specific data associated with the current state change.
    public var swiftUI: SwiftUI {
      get { self[SwiftUIKey.self] }
      set { self[SwiftUIKey.self] = newValue }
    }
  }

  extension UITransaction {
    // TODO: - Safely embed all Transaction functionallity in this type.

    /// SwiftUI-specific data associated with the current state change.
    public struct SwiftUI: Sendable {
      /// The animation, if any, associated with the current state change.
      public var animation: Animation?

      /// A Boolean value that indicates whether views should disable animations.
      public var disablesAnimations = false

      public init() {}
    }
  }

  private struct SwiftUIKey: _UICustomTransactionKey {
    static let defaultValue = UITransaction.SwiftUI()

    static func perform(value: Value, operation: () -> Void) {
      var transaction = Transaction()
      transaction.animation = value.animation
      transaction.disablesAnimations = value.disablesAnimations
      withTransaction(transaction, operation)
    }
  }
#endif
