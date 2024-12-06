#if canImport(JavaScriptCore)
  @preconcurrency import JavaScriptCore
  import WPFoundation

  // MARK: - JSFetch

  public struct JSFetchInstaller: Sendable, JSContextInstallable {
    let session: URLSession
    let cookieStorage: HTTPCookieStorage

    public func install(in context: JSContext) throws {
      try context.install([
        .request,
        .response,
        .wpJSCoreBundled(path: "fetch.js")
      ])
      let constructFetchTask: @convention(block) (JSValue) -> JSFetchTask? = { request in
        self.constructFetchTask(request: request)
      }
      context.setObject(constructFetchTask, forPath: "_wpJSCoreFetchTask")
    }

    private func constructFetchTask(request: JSValue) -> JSFetchTask? {
      let context = JSContext.current()!
      let path = request.objectForKeyedSubscript("url").toString() ?? ""
      guard let url = URL(string: path) else {
        context.exception = .typeError(message: "Failed to parse URL from \(path).", in: context)
        return nil
      }
      guard url.hasHTTPScheme else {
        context.exception = .typeError(
          message:
            "Cannot load from \(url). URL scheme \"\(url.scheme ?? "unknown")\" is not supported.",
          in: context
        )
        return nil
      }
      return JSFetchTask(
        request: URLRequest(url: url, request: request),
        session: self.session
      )
    }
  }

  extension JSContextInstallable where Self == JSFetchInstaller {
    /// An installable that installs a fetch implementation.
    public static var fetch: Self { JSFetchInstaller(session: .shared, cookieStorage: .shared) }

    /// An installable that installs a fetch implementation.
    ///
    /// - Parameters:
    ///   - session: The underlying `URLSession` to use to make HTTP requests.
    ///   - cookieStorage: The underlying `HTTPCookieStorage` to use when making HTTP requests.
    /// - Returns: An installable.
    public static func fetch(
      session: URLSession,
      cookieStorage: HTTPCookieStorage = .shared
    ) -> Self {
      JSFetchInstaller(session: session, cookieStorage: cookieStorage)
    }
  }

  // MARK: - Fetch Task

  @objc private protocol JSFetchTaskExport: JSExport {
    func perform() -> JSValue
    func cancel(_ reason: JSValue)
  }

  @objc private final class JSFetchTask: NSObject, Sendable {
    private let request: URLRequest
    private let session: URLSession
    private let state = Lock<
      (task: URLSessionDataTask?, delegate: JSURLSessionDataDelegate)
    >((nil, JSURLSessionDataDelegate()))

    init(request: URLRequest, session: URLSession) {
      self.request = request
      self.session = session
    }
  }

  extension JSFetchTask: JSFetchTaskExport {
    func perform() -> JSValue {
      JSPromise(in: .current()) { continuation in
        self.state.withLock { state in
          state.delegate.addFetchContinuation(continuation)
          guard !state.delegate.rejectIfCancelled() else { return }
          state.task = self.session.dataTask(with: self.request)
          if #available(iOS 15, macOS 12, tvOS 15, watchOS 8, *) {
            state.task?.delegate = state.delegate
          }
          state.task?.resume()
        }
      }
      .value
    }

    func cancel(_ reason: JSValue) {
      self.state.withLock {
        $0.delegate.markCancelReason(reason: reason)
        $0.task?.cancel()
        $0.task = nil
      }
    }
  }

  // MARK: - Delegate

  private final class JSURLSessionDataDelegate: NSObject {
    private let state = Lock<
      (
        body: JSFetchResponseBlobStorage?,
        cancelReason: JSValue?,
        didRedirect: Bool,
        continuation: JSPromise.Continuation?
      )
    >(
      (nil, nil, false, nil)
    )
  }

  extension JSURLSessionDataDelegate {
    func addFetchContinuation(_ continuation: JSPromise.Continuation) {
      self.state.withLock { $0.continuation = continuation }
    }

    func markCancelReason(reason: JSValue) {
      self.state.withLock { $0.cancelReason = reason }
    }

    func rejectIfCancelled() -> Bool {
      self.state.withLock { state in
        if let cancelReason = state.cancelReason {
          state.continuation?.resume(rejecting: cancelReason)
          return true
        }
        return false
      }
    }
  }

  extension JSURLSessionDataDelegate: URLSessionDataDelegate {
    func urlSession(
      _ session: URLSession,
      dataTask: URLSessionDataTask,
      didReceive response: URLResponse,
      completionHandler: @escaping @Sendable (URLSession.ResponseDisposition) -> Void
    ) {
      self.state.withLock { state in
        guard let continuation = state.continuation else { return }
        guard let response = response as? HTTPURLResponse else {
          continuation.resume(
            rejecting: JSValue(
              newErrorFromMessage: "Server responded with a non-HTTP response.",
              in: continuation.context
            )
          )
          return
        }
        let storage = JSFetchResponseBlobStorage(contentLength: response.expectedContentLength)
        continuation.resume(
          resolving: JSValue.response(
            response: response,
            body: storage,
            mimeType: response.mimeType.map { MIMEType(rawValue: $0) } ?? .empty,
            didRedirect: state.didRedirect,
            in: continuation.context
          )
        )
        state.body = storage
      }
      completionHandler(.allow)
    }

    func urlSession(
      _ session: URLSession,
      task: URLSessionTask,
      willPerformHTTPRedirection response: HTTPURLResponse,
      newRequest request: URLRequest,
      completionHandler: @escaping @Sendable (URLRequest?) -> Void
    ) {
      self.state.withLock { $0.didRedirect = true }
      completionHandler(request)
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
      self.state.withLock { state in
        state.body?.resume(with: data)
      }
    }

    func urlSession(
      _ session: URLSession,
      task: URLSessionTask,
      didCompleteWithError error: (any Error)?
    ) {
      self.state.withLock { state in
        guard let continuation = state.continuation, let error else { return }
        if let error = error as? URLError, error.code == .cancelled {
          continuation.resume(rejecting: state.cancelReason)
        } else {
          continuation.resume(
            rejecting: JSValue(
              newErrorFromMessage: error.localizedDescription,
              in: continuation.context
            )
          )
        }
        state.body?.resume(with: error)
      }
    }
  }

  // MARK: - Response Blob Storage

  private final class JSFetchResponseBlobStorage {
    private let stream: AsyncThrowingStream<String.UTF8View, any Error>
    private let continuation: AsyncThrowingStream<String.UTF8View, any Error>.Continuation
    let utf8SizeInBytes: Int

    init(contentLength: Int64) {
      let (stream, continuation) = AsyncThrowingStream<String.UTF8View, any Error>
        .makeStream(bufferingPolicy: .bufferingNewest(1))
      self.utf8SizeInBytes = Int(contentLength)
      self.stream = stream
      self.continuation = continuation
    }
  }

  extension JSFetchResponseBlobStorage: JSBlobStorage {
    func utf8Bytes(startIndex: Int, endIndex: Int) async throws(JSValueError) -> String.UTF8View {
      do {
        guard let utf8 = try await self.stream.first(where: { _ in true }) else {
          return "".utf8
        }
        return utf8.utf8Bytes(startIndex: startIndex, endIndex: endIndex)
      } catch {
        throw JSValueError(
          value: JSValue(newErrorFromMessage: error.localizedDescription, in: .current())
        )
      }
    }
  }

  extension JSFetchResponseBlobStorage {
    func resume(with data: Data) {
      self.continuation.yield(String(decoding: data, as: UTF8.self).utf8)
    }

    func resume(with error: any Error) {
      self.continuation.finish(throwing: error)
    }
  }

  // MARK: - Request

  extension URLRequest {
    fileprivate init(url: URL, request: JSValue) {
      self.init(url: url)
      var requestCopy = self
      requestCopy.httpMethod = request.objectForKeyedSubscript("method").toString()
      requestCopy.httpBody = (request.objectForKeyedSubscript("body").toArray() as? [UInt8])
        .map { Data($0) }
      let onEach: @convention(block) (JSValue) -> Void = {
        requestCopy.addValue($0.atIndex(1).toString(), forHTTPHeaderField: $0.atIndex(0).toString())
      }
      request.objectForKeyedSubscript("headers")
        .invokeMethod("forEach", withArguments: [unsafeBitCast(onEach, to: JSValue.self)])
      self = requestCopy
    }
  }

  // MARK: - Status Code

  private let statusCodeMessages = [200: "ok"]

  extension HTTPURLResponse {
    fileprivate var localizedStatusText: String {
      if let message = statusCodeMessages[self.statusCode] {
        return message
      }
      return HTTPURLResponse.localizedString(forStatusCode: self.statusCode)
    }
  }

  // MARK: - Response

  extension JSValue {
    fileprivate static func response(
      response: HTTPURLResponse,
      body: some JSBlobStorage,
      mimeType: MIMEType,
      didRedirect: Bool,
      in context: JSContext
    ) -> JSValue? {
      let responseInit = JSValue(newObjectIn: context)!
      responseInit.setValue(response.statusCode, forPath: "status")
      responseInit.setValue(response.localizedStatusText, forPath: "statusText")
      responseInit.setValue(response.allHeaderFields, forPath: "headers")
      let response = context.objectForKeyedSubscript("Response")
        .construct(withArguments: [JSBlob(storage: body, type: mimeType), responseInit])
      let privateSymbol = context.evaluateScript("Symbol._wpJSCorePrivate")
      response?.objectForKeyedSubscript(privateSymbol)
        .setValue(didRedirect, forPath: "options.redirected")
      return response
    }
  }
#endif
