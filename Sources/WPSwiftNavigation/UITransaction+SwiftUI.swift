#if canImport(SwiftUI)
  import SwiftNavigation
  import SwiftUI

  // MARK: - UITransaction

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
    
    private struct SwiftUIKey: _UICustomTransactionKey {
      static let defaultValue = SwiftUI()

      static func perform(value: Value, operation: () -> Void) {
        withTransaction(value.transaction, operation)
      }
    }
  }

  // MARK: - SwiftUI

  extension UITransaction {
    /// SwiftUI-specific data associated with the current state change.
    @dynamicMemberLookup
    public struct SwiftUI: Sendable {
      // NB: Transaction isn't Sendable, so we can instead hold all of its properties and
      // construct it from scratch each time.
      private var values = [
        any WritableKeyPath<Transaction, any Sendable> & Sendable: any Sendable
      ]()
      private var animationCompletions = [(_AnimationCompletionCriteria, @Sendable () -> Void)]()

      public init() {}
    }
  }

  extension UITransaction.SwiftUI {
    public subscript<Value: Sendable>(
      dynamicMember keyPath: WritableKeyPath<Transaction, Value>
    ) -> Value {
      get {
        let t = Transaction()
        let path = unsafeBitCast(
          keyPath,
          to: (WritableKeyPath<Transaction, Value> & Sendable).self
        )
        guard let value = self.values[\.[sendable: path]] as? Value else {
          return t[keyPath: keyPath]
        }
        return value
      }
      set {
        let path = unsafeBitCast(
          keyPath,
          to: (WritableKeyPath<Transaction, Value> & Sendable).self
        )
        self.values[\.[sendable: path]] = newValue
      }
    }
  }

  extension UITransaction.SwiftUI {
    /// Adds a completion to run when the animations created with this transaction are all
    /// complete.
    ///
    /// The completion callback will always be fired exactly one time. If no animations are created
    /// by the changes in body, then the callback will be called immediately after body.
    @available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
    public mutating func addAnimationCompletion(
      criteria: AnimationCompletionCriteria = .logicallyComplete,
      _ completion: @Sendable @escaping () -> Void
    ) {
      if criteria == .logicallyComplete {
        self.animationCompletions.append((.logicallyComplete, completion))
      } else {
        self.animationCompletions.append((.removed, completion))
      }
    }

    private enum _AnimationCompletionCriteria: Hashable, Sendable {
      case logicallyComplete
      case removed
    }
  }

  extension UITransaction.SwiftUI {
    /// The `Transaction` composed of the SwiftUI specific data.
    public var transaction: Transaction {
      var t = Transaction()
      for (path, value) in self.values {
        t[keyPath: path] = value
      }
      if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
        for (criteria, completion) in self.animationCompletions {
          switch criteria {
          case .logicallyComplete:
            t.addAnimationCompletion(criteria: .logicallyComplete, completion)
          case .removed:
            t.addAnimationCompletion(criteria: .removed, completion)
          }
        }
      }
      return t
    }
  }

  // MARK: - Helpers

  extension Transaction {
    fileprivate subscript<Value: Sendable>(
      sendable path: WritableKeyPath<Self, Value> & Sendable
    ) -> any Sendable {
      get { self[keyPath: path] as any Sendable }
      set { self[keyPath: path] = (newValue as! Value) }
    }
  }
#endif
