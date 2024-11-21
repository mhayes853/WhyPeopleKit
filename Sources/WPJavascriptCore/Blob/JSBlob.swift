#if canImport(JavaScriptCore)
  @preconcurrency import JavaScriptCore
  import WPFoundation

  // MARK: - JSBlob

  @objc private protocol JSBlobExport: JSExport {
    var size: Int { get }
    var type: String { get }

    init?(iterable: JSValue, options: JSValue)

    func text() -> JSValue
    func bytes() -> JSValue
    func arrayBuffer() -> JSValue

    func slice(_ start: JSValue, _ end: JSValue, _ type: JSValue) -> JSBlob
  }

  @objc(Blob) open class JSBlob: NSObject, JSBlobExport {
    public let type: String

    public var size: Int {
      self.storage.utf8Size
    }

    private let startIndex: Int
    private let endIndex: Int

    private let storage: any JSBlobStorage

    public required convenience init?(iterable: JSValue, options: JSValue) {
      guard let context = JSContext.current() else { return nil }
      let typeValue = options.objectForKeyedSubscript("type")
      let type = typeValue?.isUndefined == true ? "" : typeValue?.toString() ?? ""
      guard (iterable.isIterable && !iterable.isString) || iterable.isUndefined else {
        context.exception = .constructError(
          className: "Blob",
          message: "The provided value cannot be converted to a sequence.",
          in: context
        )
        return nil
      }
      guard !iterable.isUndefined else {
        self.init(storage: "", type: type)
        return
      }
      let map: @convention(block) (JSValue) -> String = { $0.toString() }
      let strings = context.objectForKeyedSubscript("Array")
        .invokeMethod("from", withArguments: [iterable])
        .invokeMethod("map", withArguments: [unsafeBitCast(map, to: JSValue.self)])
        .toArray()
        .compactMap { $0 as? String }
      self.init(storage: strings.joined(), type: type)
    }

    public init(blob: JSBlob) {
      self.type = blob.type
      self.storage = blob.storage
      self.startIndex = blob.startIndex
      self.endIndex = blob.endIndex
    }

    public init(storage: some JSBlobStorage, type: String = "") {
      self.storage = storage
      self.type = type
      self.startIndex = 0
      self.endIndex = storage.utf8Size
    }

    private init(storage: some JSBlobStorage, type: String, startIndex: Int, endIndex: Int) {
      self.storage = storage
      self.type = type
      self.startIndex = startIndex
      self.endIndex = endIndex
    }

    func text() -> JSValue {
      self.utf8Promise { utf8, _ in String(utf8) }.value
    }

    func bytes() -> JSValue {
      self.utf8Promise { bufferWithBytes(utf8: $0, in: $1).1 }.value
    }

    func arrayBuffer() -> JSValue {
      self.utf8Promise { bufferWithBytes(utf8: $0, in: $1).0 }.value
    }

    private func utf8Promise(
      _ map: @Sendable @escaping (String.UTF8View, JSContext) -> Any?
    ) -> JSPromise {
      JSPromise(in: .current()) { continuation in
        let storage = self.storage
        let startIndex = self.startIndex
        let endIndex = self.endIndex
        Task {
          await utf8(
            continuation: continuation,
            storage: storage,
            startIndex: startIndex,
            endIndex: endIndex,
            map
          )
        }
      }
    }

    func slice(_ start: JSValue, _ end: JSValue, _ type: JSValue) -> JSBlob {
      let type = type.isUndefined ? self.type : type.toString() ?? ""
      guard !start.isUndefined else { return self }
      let start = max(0, Int(start.toInt32()))
      let end = min(self.size, end.isUndefined ? self.size : Int(end.toInt32()))
      return JSBlob(storage: self.storage, type: type, startIndex: start, endIndex: end)
    }
  }

  // MARK: - Helpers

  private func bufferWithBytes(
    utf8: String.UTF8View,
    in context: JSContext
  ) -> (JSValue, JSValue) {
    let buffer = context.objectForKeyedSubscript("ArrayBuffer")
      .construct(withArguments: [utf8.count])!
    let bytes = context.objectForKeyedSubscript("Uint8Array")
      .construct(withArguments: [buffer])!
    for (index, byte) in utf8.enumerated() {
      bytes.setValue(byte, at: index)
    }
    return (buffer, bytes)
  }

  private func utf8(
    continuation: JSPromise.Continuation,
    storage: any JSBlobStorage,
    startIndex: Int,
    endIndex: Int,
    _ map: (String.UTF8View, JSContext) -> Any?
  ) async {
    do {
      continuation.resume(
        resolving: map(
          try await storage.utf8Bytes(start: startIndex, end: endIndex),
          continuation.context
        )
      )
    } catch {
      continuation.resume(rejecting: error.value)
    }
  }

  // MARK: - Blob Installer

  public struct JSBlobInstaller: JSContextInstallable {
    public func install(in context: JSContext) {
      context.setObject(JSBlob.self, forPath: "Blob")
    }
  }

  extension JSContextInstallable where Self == JSBlobInstaller {
    /// An installable that installs the Blob class.
    public static var blob: Self { JSBlobInstaller() }
  }
#endif
