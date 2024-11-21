#if canImport(JavaScriptCore)
  import JavaScriptCore
  import WPFoundation

  // MARK: - JSFile

  @objc private protocol JSFileExport: JSExport {
    var name: String { get }
    var webkitRelativePath: String { get }
    var lastModified: Int { get }
    var lastModifiedDate: Date { get }
    var size: Int { get }
    var type: String { get }

    init?(_ fileBits: JSValue, _ fileName: JSValue, _ options: JSValue)

    func text() -> JSValue
    func bytes() -> JSValue
    func arrayBuffer() -> JSValue
    func slice(_ start: JSValue, _ end: JSValue, _ type: JSValue) -> JSBlob
  }

  @objc(File) open class JSFile: JSBlob, JSFileExport {
    public let name: String
    public let lastModifiedDate: Date
    public var lastModified: Int {
      Int(round(self.lastModifiedDate.timeIntervalSince1970 * 1000))
    }
    public let webkitRelativePath = ""

    #if canImport(UniformTypeIdentifiers)
      @available(iOS 14, macOS 11, tvOS 14, watchOS 7, *)
      public convenience init(contentsOf url: URL) throws {
        try self.init(contentsOf: url, type: MIMEType(of: url)?.rawValue ?? "")
      }
    #endif

    public init(contentsOf url: URL, type: String) throws {
      let storage = try FileJSBlobStorage(url: url)
      self.lastModifiedDate = storage.lastModified
      self.name = url.lastPathComponent
      super.init(storage: storage, type: type)
    }

    public required convenience init?(
      _ fileBits: JSValue,
      _ fileName: JSValue,
      _ options: JSValue
    ) {
      guard let context = JSContext.current(), let args = JSContext.currentArguments() else {
        return nil
      }
      guard args.count >= 2 else {
        context.exception = .constructError(
          className: "File",
          message: "2 arguments required, but only \(args.count) present.",
          in: context
        )
        return nil
      }
      guard options.isObject || options.isUndefined else {
        context.exception = .constructError(
          className: "File",
          message: "The provided value is not of type 'FilePropertyBag'.",
          in: context
        )
        return nil
      }
      let file = fileBits.toObjectOf(JSFile.self) as? JSFile
      var lastModified = Date()
      let jsLastModified = options.objectForKeyedSubscript("lastModified")
      if let date = jsLastModified?.toDate() {
        lastModified = date
      } else if let dateMillis = jsLastModified?.toInt32(), jsLastModified?.isNumber == true {
        lastModified = Date(timeIntervalSince1970: Double(dateMillis / 1000))
      } else if let file {
        lastModified = file.lastModifiedDate
      }
      if let blob = fileBits.toObjectOf(JSBlob.self) {
        self.init(name: "blob", date: lastModified, blob: blob as! JSBlob)
      } else if let file {
        self.init(name: file.name, date: lastModified, blob: file)
      } else if fileBits.isIterable && !fileBits.isString,
        let blob = JSBlob(iterable: fileBits, options: options)
      {
        // TODO: - Why does using super.init(iterable:options:) make the name and lastModified of this class blank?
        self.init(name: fileName.toString() ?? "", date: lastModified, blob: blob)
      } else {
        context.exception = .constructError(
          className: "File",
          message: "The provided value cannot be converted to a sequence.",
          in: context
        )
        return nil
      }
    }

    private init(name: String, date: Date, blob: JSBlob) {
      self.name = name
      self.lastModifiedDate = date
      super.init(blob: blob)
    }

    public required convenience init?(iterable: JSValue, options: JSValue) {
      let args = JSContext.currentArguments().compactMap { $0 as? JSValue }
      self.init(iterable, options, args.count > 2 ? args[2] : JSValue(undefinedIn: .current()))
    }
  }

  // MARK: - FileJSBlobStorage

  private struct FileJSBlobStorage: JSBlobStorage {
    let lastModified: Date
    let utf8Size: Int
    private let url: URL

    init(url: URL) throws {
      let values = try url.resourceValues(forKeys: [.contentModificationDateKey, .fileSizeKey])
      self.utf8Size = values.fileSize ?? 0
      self.lastModified = values.contentModificationDate ?? Date()
      self.url = url
    }

    func utf8Bytes(start: Int, end: Int) throws(JSValueError) -> String.UTF8View {
      do {
        let string = try String(contentsOf: self.url)
        return string.utf8
      } catch {
        throw JSValueError(
          value: JSValue(newErrorFromMessage: error.localizedDescription, in: .current())
        )
      }
    }
  }

  // MARK: - Installer

  public struct JSFileInstaller: JSContextInstallable {
    public func install(in context: JSContext) {
      context.install([.blob])
      context.setObject(JSFile.self, forPath: "File")
    }
  }

  extension JSContextInstallable where Self == JSFileInstaller {
    /// An installable that installs the `File` class.
    public static var jsFileClass: Self { JSFileInstaller() }
  }
#endif
