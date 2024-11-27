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
      let installables = [.wpJSCoreBundled(paths: ["Utils.js"])] + installables
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

  // MARK: - Bundle JS Context Installable

  /// A ``JSContextInstallable`` that loads Javascript files from a bundle.
  public struct BundleFilesJSContextInstaller: JSContextInstallable {
    let paths: [String]
    let bundle: Bundle

    public func install(in context: JSContext) {
      for path in self.paths {
        guard let url = self.bundle.url(forResource: path, withExtension: nil) else { continue }
        context.evaluateScript(try! String(contentsOf: url), withSourceURL: url)
      }
    }
  }

  extension JSContextInstallable where Self == BundleFilesJSContextInstaller {
    /// An installable that loads the contents of the specified bundle pats relative to a `Bundle`.
    ///
    /// - Parameters:
    ///   - bundlePaths: A paths relative to a `Bundle`.
    ///   - bundle: The `Bundle` to load from (defaults to the main bundle).
    /// - Returns: An installable.
    public static func bundled(path bundlePath: String, in bundle: Bundle = .main) -> Self {
      BundleFilesJSContextInstaller(paths: [bundlePath], bundle: bundle)
    }

    /// An installable that loads the contents of the specified bundle paths relative to a `Bundle`.
    ///
    /// - Parameters:
    ///   - bundlePaths: An array of paths relative to a `Bundle`.
    ///   - bundle: The `Bundle` to load from (defaults to the main bundle).
    /// - Returns: An installable.
    public static func bundled(paths bundlePaths: [String], in bundle: Bundle = .main) -> Self {
      BundleFilesJSContextInstaller(paths: bundlePaths, bundle: bundle)
    }

    static func wpJSCoreBundled(paths bundledPaths: [String]) -> Self {
      .bundled(paths: bundledPaths, in: .module)
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

  extension JSContextInstallable where Self == BundleFilesJSContextInstaller {
    /// An installable that installs the `DOMException` class.
    public static var domException: Self {
      .wpJSCoreBundled(paths: ["DOMException.js"])
    }
  }

  // MARK: - Headers

  extension JSContextInstallable where Self == BundleFilesJSContextInstaller {
    /// An installable that installs the `Headers` class.
    public static var headers: Self {
      .wpJSCoreBundled(paths: ["Headers.js"])
    }
  }

  // MARK: - FormData

  extension JSContextInstallable where Self == CombinedJSContextInstallable {
    /// An installable that installs the `FormData` class.
    public static var formData: Self {
      combineInstallers([.jsFileClass, .wpJSCoreBundled(paths: ["FormData.js"])])
    }
  }
#endif
