#if canImport(JavaScriptCore)
  import JavaScriptCore
  import WPFoundation

  // MARK: - JSContextInstallable

  /// A protocol for installing functionallity into a `JSContext`.
  public protocol JSContextInstallable {
    /// Installs the functionallity of this installable into the specified context.
    ///
    /// - Parameter context: The `JSContext` to install the functionallity to.
    func install(in context: JSContext)
  }

  // MARK: - Install

  extension JSContext {
    /// Installs the specified installables to this context.
    ///
    /// - Parameter installables: A list of ``JSContextInstallable``s.
    @_disfavoredOverload
    public func install(_ installables: [any JSContextInstallable]) {
      self.setObject(JSValue(privateSymbolIn: self), forPath: "Symbol._wpJSCorePrivate")
      for installable in installables {
        installable.install(in: self)
      }
    }
  }

  // MARK: - Combine

  /// Returns an installer that combines a specified array of installers into a single installer.
  ///
  /// - Parameter installers: An array of ``JSContextInstallable`` instances.
  /// - Returns: A ``CombinedJSContextInstallable``.
  public func combineInstallers(
    _ installers: [any JSContextInstallable]
  ) -> CombinedJSContextInstallable {
    CombinedJSContextInstallable(installers: installers)
  }

  /// An installable that combines an array of ``JSContextInstallable``s into a single installer.
  public struct CombinedJSContextInstallable: JSContextInstallable {
    let installers: [any JSContextInstallable]

    public func install(in context: JSContext) {
      for installer in self.installers {
        installer.install(in: context)
      }
    }
  }

  // MARK: - FilesJSContextInstallable

  /// A ``JSContextInstallable`` that loads Javascript code from a list of `URL`s.
  public struct FilesJSContextInstallable: JSContextInstallable {
    let urls: [URL]

    public func install(in context: JSContext) {
      for url in urls {
        context.evaluateScript(try! String(contentsOf: url), withSourceURL: url)
      }
    }
  }

  extension JSContextInstallable where Self == FilesJSContextInstallable {
    /// An installable that installs the code at the specified `URL`.
    ///
    /// - Parameter url: The file `URL` of the JS code.
    /// - Returns: An installable.
    public static func file(at url: URL) -> Self {
      Self(urls: [url])
    }

    /// An installable that installs the code at the specified `URL`s.
    ///
    /// - Parameter urls: The file `URL`s of the JS code.
    /// - Returns: An installable.
    public static func files(at urls: [URL]) -> Self {
      Self(urls: urls)
    }
  }

  // MARK: - DOMException

  extension JSContextInstallable where Self == FilesJSContextInstallable {
    /// An installable that installs the `DOMException` class.
    public static var domException: Self {
      let url = Bundle.module.assumingURL(forResource: "DOMException", withExtension: "js")
      return .file(at: url)
    }
  }

  // MARK: - AbortController

  extension JSContextInstallable where Self == CombinedJSContextInstallable {
    /// An installable that installs `AbortController` and `AbortSignal` functionallity.
    public static var abortController: Self {
      let url = Bundle.module.assumingURL(forResource: "AbortController", withExtension: "js")
      return combineInstallers([.domException, .file(at: url)])
    }
  }

  // MARK: - FormData

  extension JSContextInstallable where Self == CombinedJSContextInstallable {
    /// An installable that installs the `FormData` class.
    public static var formData: Self {
      let url = Bundle.module.assumingURL(forResource: "FormData", withExtension: "js")
      return combineInstallers([.jsFileClass, .file(at: url)])
    }
  }
#endif
