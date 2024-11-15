#if canImport(JavaScriptCore)
  import JavaScriptCore

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
    public func install(_ installables: [any JSContextInstallable]) {
      for installable in installables {
        installable.install(in: self)
      }
    }
  }
#endif
