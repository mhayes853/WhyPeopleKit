import WPFoundation

// MARK: - ResponseBody

enum ResponseBody: Sendable {
  case data(Data)
  case json(any Encodable & Sendable)
}

extension ResponseBody {
  static let empty = Self.data(Data())
}

extension ResponseBody {
  fileprivate func data() throws -> Data {
    switch self {
    case let .data(data): data
    case let .json(encodable): try JSONEncoder().encode(encodable)
    }
  }
}

// MARK: - WithTestURLSession

typealias StatusCode = Int

func withTestURLSessionHandler<T: Sendable>(
  handler: @Sendable @escaping (URLRequest) async throws -> (StatusCode, ResponseBody),
  perform task: @Sendable @escaping (sending URLSession) async throws -> T
) async throws -> T {
  let configuration = URLSessionConfiguration.ephemeral
  configuration.protocolClasses = [TestURLProtocol.self]
  return try await TestURLSessionHandler.shared.withHandler { request in
    let (status, value) = try await handler(request)
    let data = try value.data()
    let response = HTTPURLResponse(
      url: request.url!,
      statusCode: status,
      httpVersion: nil,
      headerFields: ["content-length": "\(data.count)"]
    )!
    return (response, data)
  } perform: {
    try await task(URLSession(configuration: configuration))
  }
}

// MARK: - TestURLSessionHandler

private final actor TestURLSessionHandler {
  static let shared = TestURLSessionHandler()

  private var handler: @Sendable (URLRequest) async throws -> (HTTPURLResponse, Data) = { _ in
    throw UnimplementedHandlerError()
  }
  private var currentTask: Task<any Sendable, Error>?

  func withHandler<T: Sendable>(
    _ handler: @Sendable @escaping (URLRequest) async throws -> (HTTPURLResponse, Data),
    perform task: @Sendable @escaping () async throws -> T
  ) async throws -> T {
    while let currentTask {
      _ = try? await currentTask.value
    }
    let currentHandler = self.handler
    self.handler = handler
    self.currentTask = Task {
      let result = try await task()
      self.currentTask = nil
      self.handler = currentHandler
      return result
    }
    return try await self.currentTask?.cancellableValue as! T
  }

  func callAsFunction(request: URLRequest) async throws -> (HTTPURLResponse, Data) {
    try await self.handler(request)
  }
}

// MARK: - TestURLProtocol

private final class TestURLProtocol: URLProtocol, @unchecked Sendable {
  override class func canInit(with request: URLRequest) -> Bool {
    return true
  }

  override class func canonicalRequest(for request: URLRequest) -> URLRequest {
    return request
  }

  override func startLoading() {
    Task {
      do {
        let (response, data) = try await TestURLSessionHandler.shared(request: request)
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: data)
        client?.urlProtocolDidFinishLoading(self)
      } catch {
        client?.urlProtocol(self, didFailWithError: error)
      }
    }
  }

  override func stopLoading() {
  }
}

// MARK: - UnimplementedHandlerError

private struct UnimplementedHandlerError: Error {}
