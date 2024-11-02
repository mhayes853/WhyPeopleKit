#if canImport(SwiftUI)
  import SwiftUI
  import Testing
  import WPFoundation
  import WPSwiftNavigation

  @Suite("UITransaction+SwiftUI tests")
  struct UITransactionSwiftUITests {
    @Test("Edit Transaction")
    func editTransaction() {
      var transaction = UITransaction(animation: .bouncy)
      transaction.swiftUI.disablesAnimations = true

      let swiftUITransaction = transaction.swiftUI.transaction
      #expect(swiftUITransaction.animation == .bouncy)
      #expect(transaction.swiftUI.animation == .bouncy)
      #expect(swiftUITransaction.disablesAnimations)
      #expect(transaction.swiftUI.disablesAnimations)
      #expect(!swiftUITransaction.isContinuous)
      #expect(!transaction.swiftUI.isContinuous)
    }

    @Test("Edit Transaction with Custom Keys")
    @available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
    func editTransactionKeys() {
      var transaction = UITransaction(animation: .bouncy)
      transaction.swiftUI.value = "World"

      let swiftUITransaction = transaction.swiftUI.transaction
      #expect(swiftUITransaction.value == "World")
      #expect(transaction.swiftUI.value == "World")
    }
  }

  extension Transaction {
    @available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
    @Entry var value = "Hello"
  }
#endif
