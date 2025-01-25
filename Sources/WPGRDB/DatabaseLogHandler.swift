#if canImport(GRDB)
  import GRDB
  import Logging
  import WPFoundation

  /// A `LogHandler` that uses GRDB to persist logs to a SQLite database.
  public struct DatabaseLogHandler {
    private let writer: (any DatabaseWriter)?
    private let label: String
    private let date: @Sendable () -> Date
    private let rotationDuration: TimeInterval

    public var metadata = Logger.Metadata()
    public var logLevel: Logger.Level

    /// A callback that runs whenever a log message has been persisted.
    public var onLogPersisted: (@Sendable (DatabaseLog) -> Void)?

    /// Creates a database log handler.
    ///
    /// - Parameters:
    ///   - label: The label of the handler.
    ///   - path: A ``DatabasePath`` to open the logs database.
    ///   - level: The level of this logger.
    ///   - rotationDuration: The `Duration` of how long log messages last in the database.
    ///   - date: A function to return the current date.
    @available(iOS 16, macOS 13, tvOS 16, watchOS 9, *)
    public init(
      label: String,
      path: DatabasePath,
      level: Logger.Level = .info,
      rotatingEvery rotationDuration: Duration = .weeks(2),
      date: @Sendable @escaping () -> Date = { Date() }
    ) {
      self.init(
        label: label,
        path: path,
        level: level,
        rotatingEvery: TimeInterval(duration: rotationDuration),
        date: date
      )
    }

    // Creates a database log handler.
    ///
    /// - Parameters:
    ///   - label: The label of the handler.
    ///   - writer: A ``DatabaseWriter`` to use as the logs database.
    ///   - level: The level of this logger.
    ///   - rotationDuration: The `Duration` of how long log messages last in the database.
    ///   - date: A function to return the current date.
    @available(iOS 16, macOS 13, tvOS 16, watchOS 9, *)
    public init(
      label: String,
      writer: any DatabaseWriter,
      level: Logger.Level = .info,
      rotatingEvery rotationDuration: Duration = .weeks(2),
      date: @Sendable @escaping () -> Date = { Date() }
    ) {
      self.init(
        label: label,
        writer: writer,
        level: level,
        rotatingEvery: TimeInterval(duration: rotationDuration),
        date: date
      )
    }

    /// Creates a database log handler.
    ///
    /// - Parameters:
    ///   - label: The label of the handler.
    ///   - path: A ``DatabasePath`` to open the logs database.
    ///   - level: The level of this logger.
    ///   - rotationDuration: The `TimeInterval` of how long log messages last in the database.
    ///   - date: A function to return the current date.
    public init(
      label: String,
      path: DatabasePath,
      level: Logger.Level = .info,
      rotatingEvery rotationDuration: TimeInterval,
      date: @Sendable @escaping () -> Date = { Date() }
    ) {
      var migrator = DatabaseMigrator()
      migrator.registerV1()
      if let queue = try? DatabaseQueue(path: path) {
        self.writer = queue
        try? migrator.migrate(queue)
      } else {
        self.writer = nil
      }
      self.label = label
      self.logLevel = level
      self.date = date
      self.rotationDuration = rotationDuration
    }

    // Creates a database log handler.
    ///
    /// - Parameters:
    ///   - label: The label of the handler.
    ///   - writer: A ``DatabaseWriter`` to use as the logs database.
    ///   - level: The level of this logger.
    ///   - rotationDuration: The `TimeInterval` of how long log messages last in the database.
    ///   - date: A function to return the current date.
    public init(
      label: String,
      writer: any DatabaseWriter,
      level: Logger.Level = .info,
      rotatingEvery rotationDuration: TimeInterval,
      date: @Sendable @escaping () -> Date = { Date() }
    ) {
      var migrator = DatabaseMigrator()
      migrator.registerV1()
      self.writer = writer
      try? migrator.migrate(writer)
      self.label = label
      self.logLevel = level
      self.date = date
      self.rotationDuration = rotationDuration
    }
  }

  // MARK: - Accessing Logs

  extension DatabaseLogHandler {
    /// Runs a read transaction on the logs database.
    ///
    /// - Parameter fn: A function that has read access to the logs database.
    /// - Returns: Whatever `fn` returns.
    public func read<T>(_ fn: @Sendable @escaping (Database) throws -> T) async throws -> T {
      guard let writer else { throw DatabaseLogHandlerError.noReader }
      return try await writer.read { try fn($0) }
    }

    /// Runs a read transaction on the logs database.
    ///
    /// - Parameter fn: A function that has read access to the logs database.
    /// - Returns: Whatever `fn` returns.
    public func read<T>(_ fn: @Sendable @escaping (Database) throws -> T) throws -> T {
      guard let writer else { throw DatabaseLogHandlerError.noReader }
      return try writer.read { try fn($0) }
    }

    /// Returns all recorded logs.
    public func all() async throws -> [DatabaseLog] {
      try await self.read {
        try DatabaseLog.fetchAll(
          $0,
          literal: "SELECT * FROM WPGRDBDatabaseLogs ORDER BY date DESC"
        )
      }
    }
  }

  // MARK: - LogHandler

  extension DatabaseLogHandler: LogHandler {
    public subscript(metadataKey key: String) -> Logger.MetadataValue? {
      get { self.metadata[key] }
      set { self.metadata[key] = newValue }
    }

    public func log(
      level: Logger.Level,
      message: Logger.Message,
      metadata: Logger.Metadata?,
      source: String,
      file: String,
      function: String,
      line: UInt
    ) {
      let now = self.date()
      Task {
        try await self.writer?
          .write { db in
            let metadata = self.metadata.merging(metadata ?? [:]) { (_, new) in new }
            let purgeDate = now - self.rotationDuration
            try db.execute(literal: "DELETE FROM WPGRDBDatabaseLogs WHERE date < \(purgeDate)")
            let log = DatabaseLog(
              label: self.label,
              level: level,
              message: message.description,
              source: source,
              file: file,
              function: function,
              line: line,
              metadata: metadata,
              date: now
            )
            try log.insert(db)
            self.onLogPersisted?(log)
          }
      }
    }
  }

  // MARK: - Error

  public enum DatabaseLogHandlerError: Error {
    case noReader
  }

  // MARK: - Migrate

  extension DatabaseMigrator {
    fileprivate mutating func registerV1() {
      self.registerMigration("wpgrdb_logs_v1") { db in
        try db.create(table: "WPGRDBDatabaseLogs", ifNotExists: true) {
          $0.column("id", .integer).primaryKey(autoincrement: true)
          $0.column("label", .text).notNull()
          $0.column("message", .text).notNull()
          $0.column("level", .text).notNull()
          $0.column("metadata", .jsonText)
          $0.column("source", .text).notNull()
          $0.column("file", .text).notNull()
          $0.column("function", .text).notNull()
          $0.column("line", .integer).notNull()
          $0.column("date", .date).notNull()
        }
      }
    }
  }

  // MARK: - DatabaseLog

  /// A log persisted by ``DatabaseLogHandler``.
  public struct DatabaseLog: Equatable, Sendable, Codable, TableRecord, FetchableRecord,
    PersistableRecord
  {
    public static let databaseTableName = "WPGRDBDatabaseLogs"

    public let label: String
    public let level: Logger.Level
    public let message: String
    private let metadata: MetadataDatabaseValue?
    public let source: String
    public let file: String
    public let function: String
    public let line: UInt
    public let date: Date

    public var loggerMetadata: Logger.Metadata? {
      self.metadata?.metadata
    }

    public init(
      label: String,
      level: Logger.Level,
      message: String,
      source: String,
      file: String,
      function: String,
      line: UInt,
      metadata: Logger.Metadata?,
      date: Date
    ) {
      self.label = label
      self.level = level
      self.message = message
      self.source = source
      self.file = file
      self.function = function
      self.line = line
      self.metadata = metadata.map(MetadataDatabaseValue.init(metadata:))
      self.date = date
    }
  }

  // MARK: - MetadataDatabaseValue

  private struct MetadataDatabaseValue: Equatable, Sendable {
    var metadata: Logger.Metadata
  }

  // MARK: - Encodable

  extension MetadataDatabaseValue: Encodable {
    func encode(to encoder: any Encoder) throws {
      var container = encoder.container(keyedBy: AnyStringCodingKey.self)
      for (key, value) in self.metadata {
        let key = AnyStringCodingKey(stringValue: key)
        try container.encode(value.codableValue, forKey: key)
      }
    }
  }

  // MARK: - Decodable

  extension MetadataDatabaseValue: Decodable {
    init(from decoder: any Decoder) throws {
      let container = try decoder.container(keyedBy: AnyStringCodingKey.self)
      self.metadata = [:]
      for key in container.allKeys {
        let codableValue = try container.decode(MetadataValueCodable.self, forKey: key)
        self.metadata[key.stringValue] = Logger.MetadataValue(codableValue: codableValue)
      }
    }
  }

  // MARK: - MetadataValueCodable

  private enum MetadataValueCodable: Codable {
    case string(String)
    indirect case dict([String: Self])
    indirect case array([Self])
  }

  extension Logger.MetadataValue {
    fileprivate var codableValue: MetadataValueCodable {
      switch self {
      case let .string(string): .string(string)
      case let .stringConvertible(convertible): .string(convertible.description)
      case let .dictionary(metadata): .dict(metadata.mapValues(\.codableValue))
      case let .array(array): .array(array.map(\.codableValue))
      }
    }

    fileprivate init(codableValue: MetadataValueCodable) {
      switch codableValue {
      case let .string(string):
        self = .string(string)
      case let .dict(dictionary):
        self = .dictionary(dictionary.mapValues { Self(codableValue: $0) })
      case let .array(array):
        self = .array(array.map { Self(codableValue: $0) })
      }
    }
  }
#endif
