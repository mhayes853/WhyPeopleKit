#if canImport(JavaScriptCore)
  @preconcurrency import JavaScriptCore
  import Foundation

  // MARK: - JSFetch

  /// An implementation of Javascript's `fetch` for JavaScriptCore.
  public struct JSFetch: Sendable {
    private let value: JSValue

    /// Creates a JSFetch function using the specified `URLSession`.
    ///
    /// - Parameters:
    ///   - session: A `URLSession` to use for HTTP Requests.
    public init(session: URLSession = .shared) {
      // TODO: - Setup Value
      self.value = JSValue()
    }
  }

  // MARK: - Default

  extension JSFetch {
    /// The default ``JSFetch`` instance.
    public static let `default` = Self()
  }

  // MARK: - JSContextInstallable

  extension JSFetch: JSContextInstallable {
    /// Installs the `fetch` function in the specified context.
    ///
    /// - Parameter context: A `JSContext`.
    public func install(in context: JSContext) {
      context.setObject(self.value, forPath: "fetch")
    }
  }

  extension JSContextInstallable where Self == JSFetch {
    /// An installable that installs a fetch implementation.
    public static var fetch: Self { .default }

    /// An installable that installs a fetch implementation.
    ///
    /// - Parameter session: The underlying `URLSession` to use to make HTTP requests.
    /// - Returns: An installable.
    public static func fetch(session: URLSession) -> Self {
      Self(session: session)
    }
  }
#endif
