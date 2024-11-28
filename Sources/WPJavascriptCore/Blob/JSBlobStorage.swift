#if canImport(JavaScriptCore)
  import JavaScriptCore

  // MARK: - JSBlobStorage

  /// A protocol that allows the creation of ``JSBlob`` by using an arbitrary source of bytes such
  /// as a file.
  public protocol JSBlobStorage: Sendable {
    /// The size (in bytes) of the stored UTF8 content.
    var utf8SizeInBytes: Int { get }

    /// Returns the stored UTF8 bytes.
    ///
    /// - Parameters:
    ///   - startIndex: The starting index in the UTF8 data.
    ///   - endIndex: The ending index in the UTF8 data.
    /// - Throws: A ``JSValueError``.
    /// - Returns: UTF8 data.
    func utf8Bytes(startIndex: Int, endIndex: Int) async throws(JSValueError) -> String.UTF8View
  }

  // MARK: - String Conformances

  extension String: JSBlobStorage {
    public func utf8Bytes(startIndex: Int, endIndex: Int) -> String.UTF8View {
      self.utf8.utf8Bytes(startIndex: startIndex, endIndex: endIndex)
    }
  }

  extension Substring: JSBlobStorage {
    public func utf8Bytes(startIndex: Int, endIndex: Int) -> String.UTF8View {
      self.utf8.utf8Bytes(startIndex: startIndex, endIndex: endIndex)
    }
  }

  extension StringProtocol where Self: JSBlobStorage {
    public var utf8SizeInBytes: Int { self.utf8.count }
  }

  extension String.UTF8View: JSBlobStorage {
    public var utf8SizeInBytes: Int { self.count }

    public func utf8Bytes(startIndex: Int, endIndex: Int) -> Self {
      self[self.indexRange].utf8Bytes(startIndex: startIndex, endIndex: endIndex)
    }
  }

  extension Substring.UTF8View: JSBlobStorage {
    public var utf8SizeInBytes: Int { self.count }

    public func utf8Bytes(startIndex: Int, endIndex: Int) -> String.UTF8View {
      let startIndex = self.index(self.startIndex, offsetBy: startIndex)
      let endIndex = self.index(self.startIndex, offsetBy: endIndex)
      return String(Substring(self[startIndex..<endIndex])).utf8
    }
  }
#endif
