#if canImport(JavaScriptCore)
  import JavaScriptCore
  import WPFoundation

  public struct JSRequestInstaller: JSContextInstallable {
    public func install(in context: JSContext) {
      let url = Bundle.module.assumingURL(forResource: "Request", withExtension: "js")
      context.install([.formData, .headers, .abortController, .file(at: url)])
    }
  }

  extension JSContextInstallable where Self == JSRequestInstaller {
    public static var request: Self {
      JSRequestInstaller()
    }
  }
#endif
