import Foundation

extension Bundle {
  /// Returns a URL of a resource in this bundle assuming that it exists.
  ///
  /// If the resource does not exist, this function will raise a fatal error.
  ///
  /// - Parameters:
  ///   - name: The name of the resource.
  ///   - ext: The file extension of the resource.
  /// - Returns: A URL that points to the resource in this bundle.
  public func assumingURL(
    forResource name: StaticString?,
    withExtension ext: StaticString?
  ) -> URL {
    let url = self.url(
      forResource: name.map(String.init),
      withExtension: ext.map(String.init)
    )
    guard let url else {
      self.notFoundError(name: name, ext: ext, subdirectory: nil)
    }
    return url
  }

  /// Returns a URL of a resource in this bundle assuming that it exists.
  ///
  /// If the resource does not exist, this function will raise a fatal error.
  ///
  /// - Parameters:
  ///   - name: The name of the resource.
  ///   - ext: The file extension of the resource.
  ///   - subdirectory: The subdirectory that the resource is located in.
  /// - Returns: A URL that points to the resource in this bundle.
  public func assumingURL(
    forResource name: StaticString?,
    withExtension ext: StaticString?,
    subdirectory: StaticString?
  ) -> URL {
    let url = self.url(
      forResource: name.map(String.init),
      withExtension: ext.map(String.init),
      subdirectory: subdirectory.map(String.init)
    )
    guard let url else {
      self.notFoundError(name: name, ext: ext, subdirectory: subdirectory)
    }
    return url
  }

  private func notFoundError(
    name: StaticString?,
    ext: StaticString?,
    subdirectory: StaticString?
  ) -> Never {
    let name = name.map(String.init(describing:))
    let ext = ext.map(String.init(describing:))
    let subdirectory = subdirectory.map(String.init(describing:))
    switch (name, ext, subdirectory) {
    case let (.none, _, subdirectory?):
      fatalError("No resource found in subdirectory \(subdirectory) of this bundle.")
    case let (name?, ext?, subdirectory?):
      fatalError(
        "Resource \(name).\(ext) not found in subdirectory \(subdirectory) of this bundle."
      )
    case let (name?, .none, subdirectory?):
      fatalError("Resource \(name) not found in subdirectory \(subdirectory) of this bundle.")
    case let (name?, ext?, .none):
      fatalError("Resource \(name).\(ext) not found in this bundle.")
    case let (name?, .none, .none):
      fatalError("Resource \(name) not found in this bundle.")
    case (.none, _, .none):
      fatalError("Resource not found in this bundle.")
    }
  }
}
