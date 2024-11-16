#if canImport(JavaScriptCore)
  import WPJavascriptCore
  import Testing

  // Available: DataView, TypedArray, ArrayBuffer, String
  // TODO: AbortController, AbortSignal, Request, Response, fetch

  @Suite("JSFetch tests")
  struct JSFetchTests {
    private let context = JSContext()!

    @Test("Availability")
    func availability() {
      self.context.install([.consoleLogging])
      self.context.exceptionHandler = { _, value in print(value) }
      self.context.evaluateScript(
        """
        console.log("Is Available")
        console.log(DOMException)
        """
      )

    }
  }
#endif
