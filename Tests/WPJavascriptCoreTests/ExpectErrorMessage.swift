#if canImport(JavaScriptCore)
  import WPJavascriptCore
  import Testing
  import CustomDump
  import IssueReporting

  func expectErrorMessage(js: String, message expected: String, in context: JSContext) {
    var message: String?
    var didFind = false
    context.exceptionHandler = { _, value in
      guard !didFind else { return }
      message = value?.objectForKeyedSubscript("message")?.toString()
      didFind = message == expected
    }
    context.evaluateScript(js)
    expectNoDifference(message, expected)
  }
#endif
