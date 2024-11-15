import WPFoundation

// MARK: - ResponseBody

enum ResponseBody {
  case data(Data)
  case json(any Encodable)
}

// MARK: - WithTestURLSession

typealias StatusCode = Int

func withTestURLSessionHandler<T: Sendable>(
  handler: @Sendable @escaping (URLRequest) throws -> (StatusCode, ResponseBody),
  perform task: sending @escaping (URLSession) throws -> T
) async throws -> T {
  let configuration = URLSessionConfiguration.ephemeral
  configuration.protocolClasses = [TestURLProtocol.self]
  return try await TestURLSessionHandler.shared.withHandler { request in
    let (status, value) = try handler(request)
    let response = HTTPURLResponse(
      url: request.url!,
      statusCode: status,
      httpVersion: nil,
      headerFields: nil
    )!
    switch value {
    case let .data(data):
      return (response, data)
    case let .json(encodable):
      return (response, try JSONEncoder().encode(encodable))
    }
  } perform: {
    try task(URLSession(configuration: configuration))
  }
}

// MARK: - TestURLSessionHandler

private final actor TestURLSessionHandler {
  static let shared = TestURLSessionHandler()

  private var handler: @Sendable (URLRequest) throws -> (HTTPURLResponse, Data) = { _ in
    throw UnimplementedHandlerError()
  }
  private var currentTask: Task<any Sendable, Error>?

  func withHandler<T: Sendable>(
    _ handler: @Sendable @escaping (URLRequest) throws -> (HTTPURLResponse, Data),
    perform task: sending @escaping () throws -> T
  ) async throws -> T {
    while let currentTask {
      _ = try? await currentTask.value
    }
    let currentHandler = self.handler
    self.handler = handler
    self.currentTask = Task {
      let result = try task()
      self.currentTask = nil
      self.handler = currentHandler
      return result
    }
    return try await self.currentTask?.value as! T
  }

  func callAsFunction(request: URLRequest) throws -> (HTTPURLResponse, Data) {
    try self.handler(request)
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
