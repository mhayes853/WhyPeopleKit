#if canImport(JavaScriptCore)
  import JavaScriptCore

  // MARK: - JSBlobStorage

  public protocol JSBlobStorage: Sendable {
    var utf8Size: Int { get }
    func utf8Bytes(start: Int, end: Int) async throws(JSValueError) -> String.UTF8View
  }

  // MARK: - String Conformances

  extension String: JSBlobStorage {
    public func utf8Bytes(start: Int, end: Int) -> String.UTF8View {
      let startIndex = self.index(self.startIndex, offsetBy: start)
      let endIndex = self.index(self.startIndex, offsetBy: end)
      return String(Substring(self.utf8[startIndex..<endIndex])).utf8
    }
  }

  extension Substring: JSBlobStorage {
    public func utf8Bytes(start: Int, end: Int) -> String.UTF8View {
      let startIndex = self.index(self.startIndex, offsetBy: start)
      let endIndex = self.index(self.startIndex, offsetBy: end)
      return String(Substring(self.utf8[startIndex..<endIndex])).utf8
    }
  }

  extension StringProtocol where Self: JSBlobStorage {
    public var utf8Size: Int { self.utf8.count }
  }

  extension String.UTF8View: JSBlobStorage {
    public var utf8Size: Int { self.count }

    public func utf8Bytes(start: Int, end: Int) -> Self {
      let startIndex = self.index(self.startIndex, offsetBy: start)
      let endIndex = self.index(self.startIndex, offsetBy: end)
      return String(Substring(self[startIndex..<endIndex])).utf8
    }
  }

  extension String.UTF8View.SubSequence: JSBlobStorage {
    public var utf8Size: Int { self.count }

    public func utf8Bytes(start: Int, end: Int) -> String.UTF8View {
      let startIndex = self.index(self.startIndex, offsetBy: start)
      let endIndex = self.index(self.startIndex, offsetBy: end)
      return String(Substring(self[startIndex..<endIndex])).utf8
    }
  }
#endif
