import SwiftUI
import SwiftNavigation

// MARK: - Conversions

extension UIBinding {
  public init(_ binding: Binding<Value>) {
    self = UIBinding<Binding<Value>>(wrappedValue: binding)._wrappedValue
  }
}

extension Binding {
  @MainActor
  public init(_ uiBinding: UIBinding<Value>) {
    self = Bindable(BindableObject(uiBinding)).uiBinding.__wrappedValue
  }
}

// MARK: - BindableObject

@Perceptible
private final class BindableObject<Value> {
  var uiBinding: UIBinding<Value>
  
  init(_ uiBinding: UIBinding<Value>) {
    self.uiBinding = uiBinding
  }
}

// MARK: - Keypath Helpers

extension Binding {
  fileprivate var _wrappedValue: Value {
    get { self.wrappedValue }
    set { self.wrappedValue = newValue }
  }
}

extension UIBinding {
  fileprivate var __wrappedValue: Value {
    get { self.wrappedValue }
    set { self.wrappedValue = newValue }
  }
}
