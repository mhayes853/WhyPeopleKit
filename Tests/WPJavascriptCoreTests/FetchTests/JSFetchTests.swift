#if canImport(JavaScriptCore)
  import WPJavascriptCore
  import Testing
  import CustomDump
  import IssueReporting

  @Suite("JSFetch tests")
  struct JSFetchTests: @unchecked Sendable {
    private let context = JSContext()!

    init() throws {
      try self.context.install([.consoleLogging])
      self.context.exceptionHandler = { _, value in print(value) }
    }

    @Test(
      "Fetches Correct URL",
      arguments: [
        """
        new Request("https://www.example.com")
        """,
        """
        "https://www.example.com"
        """
      ]
    )
    func fetchesCorrectURL(parameters: String) async throws {
      try await withTestURLSessionHandler { request in
        if request.url != URL(string: "https://www.example.com") {
          return (404, .empty)
        }
        return (200, .empty)
      } perform: { session in
        try self.context.install([.fetch(session: session)])
        let promise = self.context
          .evaluateScript(
            """
            fetch(\(parameters))
            """
          )
          .toPromise()

        let value = try await promise?.resolvedValue
        expectNoDifference(value?.objectForKeyedSubscript("status").toInt32(), 200)
      }
    }

    @Test(
      "Fetches Response Status Text",
      arguments: [
        (200, "ok"), (204, "no content"), (404, "not found"), (403, "forbidden"),
        (500, "internal server error")
      ]
    )
    func fetchStatusText(code: Int32, text: String) async throws {
      try await withTestURLSessionHandler { request in
        return (Int(code), .empty)
      } perform: { session in
        try self.context.install([.fetch(session: session)])
        let promise = self.context
          .evaluateScript(
            """
            fetch("https://www.example.com")
            """
          )
          .toPromise()

        let value = try await promise?.resolvedValue
        expectNoDifference(value?.objectForKeyedSubscript("status").toInt32(), code)
        expectNoDifference(value?.objectForKeyedSubscript("statusText").toString(), text)
      }
    }

    @Test("Pushes Correct Headers")
    func pushesHeaders() async throws {
      let expectedHeaders = [
        "content-type": "application/json",
        "authorization": "bearer token",
        "foo": "Bar,Baz"
      ]
      try await withTestURLSessionHandler { request in
        expectNoDifference(request.allHTTPHeaderFields, expectedHeaders)
        return (200, .empty)
      } perform: { session in
        try self.context.install([.fetch(session: session)])
        let promise = self.context
          .evaluateScript(
            """
            const headers = new Headers()
            headers.set("Content-Type", "application/json")
            headers.set("Authorization", "bearer token")
            headers.set("Foo", "Bar")
            headers.append("Foo", "Baz")
            fetch("https://www.example.com", { headers })
            """
          )
          .toPromise()

        let value = try await promise?.resolvedValue
        expectNoDifference(value?.objectForKeyedSubscript("status").toInt32(), 200)
      }
    }

    @Test("Uses Correct Request Method By Default")
    func usesCorrectDefaultMethod() async throws {
      try await withTestURLSessionHandler { request in
        expectNoDifference(request.httpMethod, "GET")
        return (200, .empty)
      } perform: { session in
        try self.context.install([.fetch(session: session)])
        let promise = self.context
          .evaluateScript(
            """
            fetch("https://www.example.com")
            """
          )
          .toPromise()

        let value = try await promise?.resolvedValue
        expectNoDifference(value?.objectForKeyedSubscript("status").toInt32(), 200)
      }
    }

    @Test("Uses Correct Request Method")
    func usesCorrectSpecifiedMethod() async throws {
      try await withTestURLSessionHandler { request in
        expectNoDifference(request.httpMethod, "POST")
        return (200, .empty)
      } perform: { session in
        try self.context.install([.fetch(session: session)])
        let promise = self.context
          .evaluateScript(
            """
            fetch("https://www.example.com", { method: "POST" })
            """
          )
          .toPromise()

        let value = try await promise?.resolvedValue
        expectNoDifference(value?.objectForKeyedSubscript("status").toInt32(), 200)
      }
    }

    @Test("Pushes Body")
    func pushesBody() async throws {
      let expectedBodyData = try JSONEncoder().encode(TestBody(a: "Test", b: 42))
      try await withTestURLSessionHandler { request in
        expectNoDifference(request.httpBody, expectedBodyData)
        return (200, .empty)
      } perform: { session in
        try self.context.install([.fetch(session: session)])
        let promise = self.context
          .evaluateScript(
            """
            fetch("https://www.example.com", {
              method: "POST",
              body: JSON.stringify({ a: "Test", b: 42 })
            })
            """
          )
          .toPromise()

        let value = try await promise?.resolvedValue
        expectNoDifference(value?.objectForKeyedSubscript("status").toInt32(), 200)
      }
    }

    @Test("Pushes JS File Body as Raw Data")
    func pushesJSFileBody() async throws {
      let expectedBodyData = try JSONEncoder().encode(TestBody(a: "Test", b: 42))
      try await withTestURLSessionHandler { request in
        expectNoDifference(request.httpBody, expectedBodyData)
        return (200, .empty)
      } perform: { session in
        try self.context.install([.fetch(session: session)])
        let promise = self.context
          .evaluateScript(
            """
            fetch("https://www.example.com", {
              method: "POST",
              body: new File([JSON.stringify({ a: "Test", b: 42 })], "test.txt")
            })
            """
          )
          .toPromise()

        let value = try await promise?.resolvedValue
        expectNoDifference(value?.objectForKeyedSubscript("status").toInt32(), 200)
      }
    }

    @Test("Pushes Native File Body as Data")
    func pushesNativeFileBody() async throws {
      let url = URL.temporaryDirectory.appending(path: "\(UUID()).json")
      let expectedBodyData = try JSONEncoder().encode(TestBody(a: "Test", b: 42))
      try expectedBodyData.write(to: url)
      try await withTestURLSessionHandler { request in
        expectNoDifference(request.httpBody, expectedBodyData)
        return (200, .empty)
      } perform: { session in
        try self.context.install([.fetch(session: session)])
        self.context.setObject(try JSFile(contentsOf: url), forPath: "testFile")
        let promise = self.context
          .evaluateScript(
            """
            fetch("https://www.example.com", { method: "POST", body: testFile })
            """
          )
          .toPromise()

        let value = try await promise?.resolvedValue
        expectNoDifference(value?.objectForKeyedSubscript("status").toInt32(), 200)
      }
    }

    @Test("Throws Error When Invalid URL")
    func invalidURL() async throws {
      try self.context.install([.fetch])
      try await expectPromiseRejectedErrorMessage(
        js: """
          fetch("")
          """,
        message: "Failed to parse URL from .",
        in: self.context
      )
    }

    @Test(
      "Throws Error When Non-HTTP URL",
      arguments: [("blob://test.com", "blob"), ("file:///test.txt", "file")]
    )
    func nonHTTPURL(url: String, scheme: String) async throws {
      try self.context.install([.fetch])
      try await expectPromiseRejectedErrorMessage(
        js: """
          fetch("\(url)")
          """,
        message: "Cannot load from \(url). URL scheme \"\(scheme)\" is not supported.",
        in: self.context
      )
    }

    @Test("Fetch JSON")
    func fetchJSON() async throws {
      let expectedBody = TestBody(a: "Hello", b: 2)
      try await withTestURLSessionHandler { request in
        if request.url != URL(string: "https://example.com/api/test") {
          return (404, .empty)
        }
        return (200, .json(expectedBody))
      } perform: { session in
        try self.context.install([.fetch(session: session)])
        let promise = self.context
          .evaluateScript(
            """
            fetch("https://example.com/api/test").then((resp) => resp.json())
            """
          )
          .toPromise()

        let value = try await promise?.resolvedValue
        expectNoDifference(value?.objectForKeyedSubscript("a").toString(), expectedBody.a)
        expectNoDifference(value?.objectForKeyedSubscript("b").toInt32(), expectedBody.b)
      }
    }

    @Test("Fetch Text")
    func fetchText() async throws {
      try await withTestURLSessionHandler { request in
        if request.url != URL(string: "https://example.com/api/test") {
          return (404, .empty)
        }
        return (200, .data(Data("text".utf8)))
      } perform: { session in
        try self.context.install([.fetch(session: session)])
        let promise = self.context
          .evaluateScript(
            """
            fetch("https://example.com/api/test").then((resp) => resp.text())
            """
          )
          .toPromise()

        let value = try await promise?.resolvedValue
        expectNoDifference(value?.toString(), "text")
      }
    }

    @Test("Fetch Bytes")
    func fetchBytes() async throws {
      try await withTestURLSessionHandler { request in
        if request.url != URL(string: "https://example.com/api/test") {
          return (404, .empty)
        }
        return (200, .data(Data([0x66, 0x6F, 0x6F])))
      } perform: { session in
        try self.context.install([.fetch(session: session)])
        let promise = self.context
          .evaluateScript(
            """
            fetch("https://example.com/api/test").then((resp) => resp.bytes())
            """
          )
          .toPromise()

        let value = try await promise?.resolvedValue
        expectNoDifference(value?.toArray().compactMap { $0 as? UInt8 }, [0x66, 0x6F, 0x6F])
      }
    }

    @Test("Throws Error When Non-HTTP Response")
    func nonHTTPResponse() async throws {
      let configuration = URLSessionConfiguration.ephemeral
      configuration.protocolClasses = [NonHTTPResponseProtocol.self]
      try self.context.install([
        .fetch(session: URLSession(configuration: configuration))
      ])
      try await expectPromiseRejectedErrorMessage(
        js: """
          fetch("https://example.com/api/test")
          """,
        message: "Server responded with a non-HTTP response.",
        in: self.context
      )
    }

    @Test("Throws Abort Error When Request Aborted Before Fetching")
    func throwsAbortErrorBeforeFetch() async throws {
      try await withTestURLSessionHandler { _ in
        reportIssue("Should not make request.")
        return (500, .empty)
      } perform: { session in
        try self.context.install([.fetch(session: session)])
        try await expectPromiseRejectedErrorMessage(
          js: """
            const get = async () => {
              const controller = new AbortController()
              const request = new Request("https://youtube.com", { signal: controller.signal })
              controller.abort()
              await fetch(request)
            }
            get()
            """,
          message: "signal is aborted without reason",
          in: self.context
        )
      }
    }

    @Test("Throws Abort Error When Request Aborted When Loading Body")
    func throwsAbortErrorWhenLoadingBody() async throws {
      try await withTestURLSessionHandler { _ in
        reportIssue("Should not make request.")
        return (500, .empty)
      } perform: { session in
        try self.context.install([.fetch(session: session)])
        try await expectPromiseRejectedErrorMessage(
          js: """
            const get = async () => {
              const controller = new AbortController()
              const promise = fetch("https://youtube.com", { signal: controller.signal })
              controller.abort()
              await promise
            }
            get()
            """,
          message: "signal is aborted without reason",
          in: self.context
        )
      }
    }

    @Test("Throws Abort Error When Request Aborted During Fetch")
    func throwsAbortErrorDuringFetch() async throws {
      try await withTestURLSessionHandler { _ in
        return (500, .empty)
      } perform: { session in
        try self.context.install([.fetch(session: session)])
        try await expectPromiseRejectedErrorMessage(
          js: """
            const get = async () => {
              const controller = new AbortController()
              const promise = fetch("https://youtube.com", { signal: controller.signal })
              controller.abort()
              await promise
            }
            get()
            """,
          message: "signal is aborted without reason",
          in: self.context
        )
      }
    }

    @Test("Resolves After Request Completes")
    func resolvesAfterRequest() async throws {
      let configuration = URLSessionConfiguration.ephemeral
      configuration.protocolClasses = [NoBodyResponseProtocol.self]
      try self.context.install([
        .fetch(session: URLSession(configuration: configuration))
      ])
      let promise = self.context
        .evaluateScript(
          """
          fetch("https://www.example.com")
          """
        )
        .toPromise()
      let value = try await promise?.resolvedValue
      expectNoDifference(value?.objectForKeyedSubscript("status").toInt32(), 200)
    }

    @Test("Throws Error When Request Throws")
    func throwsWhenRequestThrows() async throws {
      try await withTestURLSessionHandler { _ in
        throw URLError(.networkConnectionLost)
      } perform: { session in
        try self.context.install([.fetch(session: session)])
        try await expectPromiseRejectedErrorMessage(
          js: """
            fetch("https://www.example.com")
            """,
          message: "The operation couldn’t be completed. (NSURLErrorDomain error -1005.)",
          in: self.context
        )
      }
    }

    @Test("Request Response Headers")
    func responseHeaders() async throws {
      try await withTestURLSessionHandler { _ in
        return (200, .data(Data("test".utf8)))
      } perform: { session in
        try self.context.install([.fetch(session: session)])
        let promise = self.context
          .evaluateScript(
            """
            fetch("https://www.example.com").then((resp) => Array.from(resp.headers))
            """
          )
          .toPromise()
        let value = try await promise?.resolvedValue
        expectHeaders(
          from: value,
          toEqual: [["content-length", "4"], ["content-type", "text/plain"]]
        )
      }
    }

    @Test("Normal Response is Not Redirected")
    func notRedirected() async throws {
      try await withTestURLSessionHandler { _ in
        return (200, .data(Data("test".utf8)))
      } perform: { session in
        try self.context.install([.fetch(session: session)])
        let promise = self.context
          .evaluateScript(
            """
            fetch("https://www.example.com")
            """
          )
          .toPromise()
        let value = try await promise?.resolvedValue
        expectNoDifference(value?.objectForKeyedSubscript("status").toInt32(), 200)
        expectNoDifference(value?.objectForKeyedSubscript("redirected").toBool(), false)
      }
    }

    @Test("Response Indicates Redirects")
    func responseIndicatesRedirects() async throws {
      let configuration = URLSessionConfiguration.ephemeral
      configuration.protocolClasses = [RedirectProtocol.self]
      try self.context.install([
        .fetch(session: URLSession(configuration: configuration))
      ])
      let promise = self.context
        .evaluateScript(
          """
          fetch("https://www.example.com")
          """
        )
        .toPromise()
      let value = try await promise?.resolvedValue
      expectNoDifference(value?.objectForKeyedSubscript("status").toInt32(), 200)
      expectNoDifference(value?.objectForKeyedSubscript("redirected").toBool(), true)
    }
  }

  private final class RedirectProtocol: URLProtocol {
    override class func canInit(with request: URLRequest) -> Bool {
      return request.url != URL(string: "https://www.google.com")
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
      return request
    }

    override func startLoading() {
      let response = HTTPURLResponse(
        url: request.url!,
        statusCode: 301,
        httpVersion: nil,
        headerFields: nil
      )!
      client?
        .urlProtocol(
          self,
          wasRedirectedTo: URLRequest(
            url: URL(string: "https://www.google.com")!,
            cachePolicy: .reloadIgnoringCacheData,
            timeoutInterval: 10
          ),
          redirectResponse: response
        )

      let response2 = HTTPURLResponse(
        url: request.url!,
        statusCode: 200,
        httpVersion: nil,
        headerFields: nil
      )!
      client?.urlProtocol(self, didReceive: response2, cacheStoragePolicy: .allowed)
      client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {
    }
  }

  private final class NoBodyResponseProtocol: URLProtocol {
    override class func canInit(with request: URLRequest) -> Bool {
      return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
      return request
    }

    override func startLoading() {
      let response = HTTPURLResponse(
        url: request.url!,
        statusCode: 200,
        httpVersion: nil,
        headerFields: nil
      )!
      client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
      client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {
    }
  }

  private final class NonHTTPResponseProtocol: URLProtocol {
    override class func canInit(with request: URLRequest) -> Bool {
      return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
      return request
    }

    override func startLoading() {
      let response = URLResponse(
        url: self.request.url!,
        mimeType: nil,
        expectedContentLength: 0,
        textEncodingName: nil
      )
      client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
      client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {
    }
  }

  private struct TestBody: Codable {
    let a: String
    let b: Int32
  }
#endif
