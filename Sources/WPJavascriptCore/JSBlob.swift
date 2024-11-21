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
    public let size: Int
    public let type: String
    private let contents: String.UTF8View.SubSequence

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
        self.init(contents: "".utf8, type: type)
        return
      }
      let map: @convention(block) (JSValue) -> String = { $0.toString() }
      let strings = context.objectForKeyedSubscript("Array")
        .invokeMethod("from", withArguments: [iterable])
        .invokeMethod("map", withArguments: [unsafeBitCast(map, to: JSValue.self)])
        .toArray()
        .compactMap { $0 as? String }
      self.init(contents: strings.joined().utf8, type: type)
    }

    public init(blob: JSBlob) {
      self.size = blob.size
      self.type = blob.type
      self.contents = blob.contents
    }

    private init(contents: String.UTF8View, type: String) {
      self.contents = contents[contents.indexRange]
      self.size = contents.count
      self.type = type
    }

    private init(contents: String.UTF8View.SubSequence, type: String) {
      self.contents = contents
      self.size = contents.count
      self.type = type
    }

    func text() -> JSValue {
      JSPromise(in: .current()) { continuation in
        continuation.resume(resolving: String(self.contents))
      }
      .value
    }

    func bytes() -> JSValue {
      JSPromise(in: .current()) { continuation in
        let (_, bytes) = self.bufferWithBytes(in: continuation.context)
        continuation.resume(resolving: bytes)
      }
      .value
    }

    func arrayBuffer() -> JSValue {
      JSPromise(in: .current()) { continuation in
        let (buffer, _) = self.bufferWithBytes(in: continuation.context)
        continuation.resume(resolving: buffer)
      }
      .value
    }

    private func bufferWithBytes(in context: JSContext) -> (JSValue, JSValue) {
      let buffer = context.objectForKeyedSubscript("ArrayBuffer")
        .construct(withArguments: [self.size])!
      let bytes = context.objectForKeyedSubscript("Uint8Array")
        .construct(withArguments: [buffer])!
      for (index, byte) in self.contents.enumerated() {
        bytes.setValue(byte, at: index)
      }
      return (buffer, bytes)
    }

    func slice(_ start: JSValue, _ end: JSValue, _ type: JSValue) -> JSBlob {
      let type = type.isUndefined ? self.type : type.toString() ?? ""
      guard !start.isUndefined else { return JSBlob(contents: self.contents, type: type) }
      let start = max(0, Int(start.toInt32()))
      let startIndex = self.contents.index(self.contents.startIndex, offsetBy: start)
      let end = min(self.size, end.isUndefined ? self.size : Int(end.toInt32()))
      let endIndex = self.contents.index(self.contents.startIndex, offsetBy: end)
      return JSBlob(contents: self.contents[startIndex..<endIndex], type: type)
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
