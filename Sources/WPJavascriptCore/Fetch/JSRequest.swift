#if canImport(JavaScriptCore)
  import JavaScriptCore
  import WPFoundation

  public struct JSRequestInstaller: JSContextInstallable {
    public func install(in context: JSContext) {
      context.install([
        .formData, .headers, .abortController,
        .wpJSCoreBundled(paths: ["HTTPBody.js", "Request.js"])
      ])
    }
  }

  extension JSContextInstallable where Self == JSRequestInstaller {
    public static var request: Self {
      JSRequestInstaller()
    }
  }
#endif
