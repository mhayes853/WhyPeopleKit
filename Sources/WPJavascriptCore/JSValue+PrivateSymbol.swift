#if canImport(JavaScriptCore)
  import JavaScriptCore

  extension JSValue {
    convenience init(privateSymbolIn context: JSContext) {
      self.init(newSymbolFromDescription: "_wpJSCorePrivate", in: context)
    }
  }
#endif
