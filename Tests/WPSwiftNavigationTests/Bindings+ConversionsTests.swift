import WPSwiftNavigation
import Testing
import SwiftUI

@MainActor
@Suite("Bindings+Conversions tests")
struct BindingsConversionsTests {
  @Test("Binding to UIBinding")
  func bindingToUIBinding() async throws {
    let model = TextModel()
    let textBinding = Binding(get: { model.text }, set: { model.text = $0 })
    let uiTextBinding = UIBinding(textBinding)
    uiTextBinding.wrappedValue = "hello"
    #expect(model.text == "hello")
    #expect(textBinding.wrappedValue == "hello")
  }
  
  @Test("UIBinding to Binding")
  func uiBindingToBinding() async throws {
    let model = TextModel()
    @UIBindable var textModel = model
    let textBinding = Binding($textModel.text)
    textBinding.wrappedValue = "hello"
    #expect(model.text == "hello")
    #expect(textModel.text == "hello")
  }
}

@MainActor
@Perceptible
private final class TextModel {
  var text = ""
}
