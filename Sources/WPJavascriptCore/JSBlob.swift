#if canImport(JavaScriptCore)
  @preconcurrency import JavaScriptCore
  import WPFoundation

  @objc private protocol JSBlobExport: JSExport {
    init(iterable: JSValue, options: JSValue)

    var size: Int { get }
    var type: String { get }
    func text() -> JSValue
    func arrayBuffer() -> JSValue

    func slice(_ start: JSValue, _ end: JSValue, _ type: JSValue) -> JSBlobExport
  }

  @objc private final class JSBlob: NSObject, JSBlobExport, Sendable {
    let size: Int
    let type: String
    private let contents: String.UTF8View.SubSequence

    required convenience init(iterable: JSValue, options: JSValue) {
      let type = options.objectForKeyedSubscript("type").toString() ?? ""
      guard !iterable.isUndefined else {
        let utf8View = "".utf8
        self.init(contents: utf8View[utf8View.indexRange], type: type)
        return
      }
      let map: @convention(block) (JSValue) -> String = { $0.toString() }
      let strings = iterable.context.objectForKeyedSubscript("Array")
        .invokeMethod("from", withArguments: [iterable])
        .invokeMethod("map", withArguments: [unsafeBitCast(map, to: JSValue.self)])
        .toArray()
        .compactMap { $0 as? String }
      let utf8View = strings.joined().utf8
      self.init(contents: utf8View[utf8View.indexRange], type: type)
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

    func arrayBuffer() -> JSValue {
      JSPromise(in: .current()) { continuation in
        let buffer = continuation.context.objectForKeyedSubscript("ArrayBuffer")
          .construct(withArguments: [self.size])!
        let bytes = continuation.context.objectForKeyedSubscript("Uint8Array")
          .construct(withArguments: [buffer])
        for (index, byte) in self.contents.enumerated() {
          bytes?.setValue(byte, at: index)
        }
        continuation.resume(resolving: buffer)
      }
      .value
    }

    func slice(_ start: JSValue, _ end: JSValue, _ type: JSValue) -> any JSBlobExport {
      let type = type.isUndefined ? self.type : type.toString() ?? ""
      guard !start.isUndefined else { return JSBlob(contents: self.contents, type: type) }
      let start = max(0, Int(start.toInt32()))
      let startIndex = self.contents.index(self.contents.startIndex, offsetBy: start)
      let end = min(self.size, end.isUndefined ? self.size : Int(end.toInt32()))
      let endIndex = self.contents.index(self.contents.startIndex, offsetBy: end)
      return JSBlob(contents: self.contents[startIndex..<endIndex], type: type)
    }
  }

  public struct JSBlobInstaller: JSContextInstallable {
    public func install(in context: JSContext) {
      context.install([
        .file(at: Bundle.module.assumingURL(forResource: "Blob", withExtension: "js"))
      ])
      context.setObject(JSBlob.self, forPath: "_WPJSCoreBlob")
    }
  }

  extension JSContextInstallable where Self == JSBlobInstaller {
    /// An installable that installs the Blob class.
    public static var blob: Self { JSBlobInstaller() }
  }
#endif
