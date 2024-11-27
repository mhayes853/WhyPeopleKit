#if canImport(JavaScriptCore)
  import JavaScriptCore
  import WPFoundation

  // MARK: - JSContextInstallable

  /// A protocol for installing functionallity into a `JSContext`.
  public protocol JSContextInstallable {
    /// A Hashable value that can be used to deduplicate installs.
    ///
    /// If this value is nil, then this installable can be installed multiple times.
    var installKey: AnyHashable? { get }

    /// Installs the functionallity of this installable into the specified context.
    ///
    /// - Parameter context: The `JSContext` to install the functionallity to.
    func install(in context: JSContext)
  }

  extension JSContextInstallable {
    public var installKey: AnyHashable? { nil }
  }

  // MARK: - Install

  extension JSContext {
    private static nonisolated(unsafe) let installKeysKey = malloc(1)!
    private static nonisolated(unsafe) let installLockKey = malloc(1)!

    /// Installs the specified installables to this context.
    ///
    /// - Parameter installables: A list of ``JSContextInstallable``s.
    @_disfavoredOverload
    public func install(_ installables: [any JSContextInstallable]) {
      self.installLock.withLock {
        self.setObject(JSValue(privateSymbolIn: self), forPath: "Symbol._wpJSCorePrivate")
        for installable in [.wpJSCoreBundled(path: "Utils.js")] + installables {
          if let key = installable.installKey, self.installedKeys.contains(key) {
            continue
          }
          if let key = installable.installKey {
            self.installedKeys.insert(key)
          }
          installable.install(in: self)
        }
      }
    }

    private var installLock: NSRecursiveLock {
      get {
        if let lock = objc_getAssociatedObject(self, Self.installLockKey) as? NSRecursiveLock {
          return lock
        }
        let lock = NSRecursiveLock()
        self.installLock = lock
        return lock
      }
      set {
        objc_setAssociatedObject(
          self,
          Self.installLockKey,
          newValue,
          .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )
      }
    }

    private var installedKeys: Set<AnyHashable> {
      get {
        objc_getAssociatedObject(self, Self.installKeysKey) as? Set<AnyHashable> ?? []
      }
      set {
        objc_setAssociatedObject(
          self,
          Self.installKeysKey,
          newValue,
          .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )
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
      context.install(self.installers)
    }
  }

  // MARK: - Bundle JS Context Installable

  /// A ``JSContextInstallable`` that loads Javascript files from a bundle.
  public struct BundleFileJSContextInstaller: JSContextInstallable {
    fileprivate struct Values: Hashable {
      let path: String
      let bundle: Bundle
    }

    fileprivate let values: Values

    public var installKey: AnyHashable {
      self.values
    }

    public func install(in context: JSContext) {
      guard let url = self.values.bundle.url(forResource: self.values.path, withExtension: nil)
      else { return }
      context.evaluateScript(try! String(contentsOf: url), withSourceURL: url)
    }
  }

  extension JSContextInstallable where Self == BundleFileJSContextInstaller {
    /// An installable that loads the contents of the specified bundle pats relative to a `Bundle`.
    ///
    /// - Parameters:
    ///   - bundlePaths: A paths relative to a `Bundle`.
    ///   - bundle: The `Bundle` to load from (defaults to the main bundle).
    /// - Returns: An installable.
    public static func bundled(path bundlePath: String, in bundle: Bundle = .main) -> Self {
      BundleFileJSContextInstaller(
        values: BundleFileJSContextInstaller.Values(path: bundlePath, bundle: bundle)
      )
    }

    static func wpJSCoreBundled(path bundledPath: String) -> Self {
      .bundled(path: bundledPath, in: .module)
    }
  }

  extension JSContextInstallable where Self == CombinedJSContextInstallable {
    /// An installable that loads the contents of the specified bundle paths relative to a `Bundle`.
    ///
    /// - Parameters:
    ///   - bundlePaths: An array of paths relative to a `Bundle`.
    ///   - bundle: The `Bundle` to load from (defaults to the main bundle).
    /// - Returns: An installable.
    public static func bundled(paths bundlePaths: [String], in bundle: Bundle = .main) -> Self {
      combineInstallers(bundlePaths.map { .bundled(path: $0, in: bundle) })
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

  extension JSContextInstallable where Self == CombinedJSContextInstallable {
    /// An installable that installs the `DOMException` class.
    public static var domException: Self {
      .wpJSCoreBundled(paths: ["DOMException.js"])
    }
  }

  // MARK: - Headers

  extension JSContextInstallable where Self == CombinedJSContextInstallable {
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
