extension Result where Success: ~Copyable {
  /// Creates a new result by evaluating an async throwing closure, capturing the returned value as
  /// a success, or any thrown error as a failure.
  ///
  /// - Parameter body: A throwing closure to evaluate.
  public init(catching body: () async throws(Failure) -> Success) async {
    do {
      self = .success(try await body())
    } catch {
      self = .failure(error)
    }
  }
}
