import Foundation
import GRDB
import IssueReporting

// MARK: - SqlitePath

/// A strong data type for the physical location of a sqlite database.
public enum DatabasePath: Hashable, Sendable {
  case url(URL)
  case inMemory(named: String?)
}

extension DatabasePath {
  public static let inMemory = Self.inMemory(named: nil)
}

// MARK: - DatabaseQueue Extension

extension DatabaseQueue {
  /// Opens or creates a SQLite database at the specified ``DatabasePath``.
  ///
  /// - Parameters:
  ///   - path: A ``DatabasePath``.
  ///   - configuration: A `Configuration`.
  public convenience init(
    path: DatabasePath,
    configuration: Configuration = Configuration()
  ) throws {
    try FileManager.default.createPathComponentsIfNeeded(at: path)
    switch path {
    case let .inMemory(named):
      try self.init(named: named, configuration: configuration)
    case let .url(url):
      try self.init(path: url.description, configuration: configuration)
    }
  }
}

// MARK: - DatabasePool Extension

extension DatabasePool {
  /// Opens or creates a SQLite database at the specified ``DatabasePath``
  ///
  /// You cannot create in-memory database pools, this initializer will throw if the path is an
  /// in-memory path.
  ///
  /// - Parameters:
  ///   - path: A ``DatabasePath``.
  ///   - configuration: A `Configuration`.
  public convenience init(
    path: DatabasePath,
    configuration: Configuration = Configuration()
  ) throws {
    try FileManager.default.createPathComponentsIfNeeded(at: path)
    switch path {
    case .inMemory:
      reportIssue("DatabasePools cannot be created with in memory paths.")
      try self.init(path: ":memory:")
    case let .url(url):
      try self.init(path: url.description)
    }
  }
}

// MARK: - Helpers

extension FileManager {
  fileprivate func createPathComponentsIfNeeded(at path: DatabasePath) throws {
    switch path {
    case let .url(url):
      try self.createDirectory(
        at: url.deletingLastPathComponent(),
        withIntermediateDirectories: true
      )
    case .inMemory:
      break
    }
  }
}
