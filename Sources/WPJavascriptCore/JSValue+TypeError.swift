#if canImport(JavaScriptCore)
  import JavaScriptCore

  extension JSValue {
    public static func typeError(message: String, in context: JSContext) -> JSValue {
      context.objectForKeyedSubscript("TypeError").construct(withArguments: [message])
    }
  }
#endif
