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
    /// - Parameter installable: A variadic list of ``JSContextInstallable``s.
    public func install<each I: JSContextInstallable>(_ installable: (repeat each I)) {
      for installer in repeat each installable {
        installer.install(in: self)
      }
    }

    /// Installs the specified installables to this context.
    ///
    /// - Parameter installables: A list of ``JSContextInstallable``s.
    @_disfavoredOverload
    public func install(_ installables: [any JSContextInstallable]) {
      for installable in installables {
        installable.install(in: self)
      }
    }
  }

  // MARK: - FilesJSContextInstallable

  /// A ``JSContextInstallable`` that loads Javascript code from a list of `URL`s.
  public struct FilesJSContextInstallable: JSContextInstallable {
    let urls: [URL]

    public func install(in context: JSContext) {
      for url in self.urls {
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

  // MARK: - AbortController

  extension JSContextInstallable where Self == FilesJSContextInstallable {
    /// An installable that installs `AbortController` and `AbortSignal` functionallity.
    public static var abortController: Self {
      let url = Bundle.module.assumingURL(forResource: "AbortController", withExtension: "js")
      return .file(at: url)
    }
  }
#endif
