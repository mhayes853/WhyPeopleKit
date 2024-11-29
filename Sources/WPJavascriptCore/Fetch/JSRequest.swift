#if canImport(JavaScriptCore)
  import JavaScriptCore
  import WPFoundation

  public struct JSRequestInstaller: JSContextInstallable {
    private let base = combineInstallers([
      .formData, .headers, .abortController,
      .wpJSCoreBundled(path: "HTTPBody.js"),
      .wpJSCoreBundled(path: "HTTPOptions.js"),
      .wpJSCoreBundled(path: "Request.js")
    ])

    public func install(in context: JSContext) throws {
      try self.base.install(in: context)
    }
  }

  extension JSContextInstallable where Self == JSRequestInstaller {
    /// An installable that installs Javascript's `Request` class.
    public static var request: Self { JSRequestInstaller() }
  }
#endif
