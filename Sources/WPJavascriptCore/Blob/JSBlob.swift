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
      self.indexedStorage.storage.utf8Size
    }

    private let indexedStorage: IndexedStorage

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
      self.indexedStorage = blob.indexedStorage
    }

    public init(storage: some JSBlobStorage, type: String = "") {
      self.type = type
      self.indexedStorage = IndexedStorage(
        startIndex: 0,
        endIndex: storage.utf8Size,
        storage: storage
      )
    }

    private init(state: IndexedStorage, type: String) {
      self.indexedStorage = state
      self.type = type
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
        let indexedStorage = self.indexedStorage
        Task { await indexedStorage.utf8(continuation: continuation, map) }
      }
    }

    func slice(_ start: JSValue, _ end: JSValue, _ type: JSValue) -> JSBlob {
      let type = type.isUndefined ? self.type : type.toString() ?? ""
      guard !start.isUndefined else { return self }
      var state = self.indexedStorage
      state.startIndex = max(0, Int(start.toInt32()))
      state.endIndex = min(self.size, end.isUndefined ? self.size : Int(end.toInt32()))
      return JSBlob(state: state, type: type)
    }
  }

  // MARK: - Helpers

  extension JSBlob {
    private struct IndexedStorage: Sendable {
      var startIndex: Int
      var endIndex: Int
      let storage: any JSBlobStorage

      func utf8(
        continuation: JSPromise.Continuation,
        _ map: (String.UTF8View, JSContext) -> Any?
      ) async {
        do {
          continuation.resume(
            resolving: map(
              try await self.storage.utf8Bytes(start: self.startIndex, end: self.endIndex),
              continuation.context
            )
          )
        } catch {
          continuation.resume(rejecting: error.value)
        }
      }
    }
  }

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
