#if canImport(JavaScriptCore)
  import JavaScriptCore
  import WPFoundation
  import Security

  // MARK: - Installer

  public struct JSCryptoInstaller: JSContextInstallable {
    public func install(in context: JSContext) throws {
      let randomUUID: @convention(block) () -> String = { "\(UUID())".lowercased() }
      let randomBytes: @convention(block) (Int) -> [UInt8] = { self.randomBytes(count: $0) }
      context.setObject(randomUUID, forPath: "_wpJSCoreRandomUUID")
      context.setObject(randomBytes, forPath: "_wpJSCoreRandomBytes")
      try context.install([.wpJSCoreBundled(path: "Crypto.js")])
    }

    private func randomBytes(count: Int) -> [UInt8] {
      var bytes = [UInt8](repeating: 0, count: count)
      let result = SecRandomCopyBytes(kSecRandomDefault, count, &bytes)
      if result != errSecSuccess {
        JSContext.current()?.exception = JSValue(
          newErrorFromMessage: SecError(code: result).message,
          in: .current()
        )
      }
      return bytes
    }
  }

  extension JSContextInstallable where Self == JSCryptoInstaller {
    /// An installable that installs web browser crypto operations.
    ///
    /// `crypto.subtle` is not supported, only `crypto.getRandomValues` and `crypto.randomUUID`
    /// are supported.
    public static var crypto: Self { JSCryptoInstaller() }
  }
#endif
