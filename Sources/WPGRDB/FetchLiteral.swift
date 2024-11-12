#if canImport(GRDB)
  import GRDB

  // MARK: - DatabaseValueConvertible

  extension DatabaseValueConvertible where Self: StatementColumnConvertible {
    /// Returns a single value fetched from an SQL query.
    ///
    /// The value is decoded from the leftmost column if the `adapter` argument
    /// is nil.
    ///
    /// The result is nil if the request returns no row, or one row with a
    /// `NULL` value.
    ///
    /// For example:
    ///
    /// ```swift
    /// try dbQueue.read { db in
    ///     let lastName = "O'Reilly"
    ///     let score = try Int.fetchOne(db, literal: "SELECT score FROM player WHERE lastName = \(lastName)")
    /// }
    /// ```
    ///
    /// - parameters:
    ///     - db: A database connection.
    ///     - literal: An `SQL` literal.
    ///     - adapter: Optional RowAdapter.
    ///     - cached: Defaults to false. If true, the request reuses a cached prepared statement.
    /// - returns: An optional value.
    /// - throws: A ``DatabaseError`` whenever an SQLite error occurs.
    public static func fetchOne(
      _ db: Database,
      literal: SQL,
      adapter: RowAdapter? = nil,
      cached: Bool = false
    ) throws -> Self? {
      let request = SQLRequest(literal: literal, adapter: adapter, cached: cached)
      return try Self.fetchOne(db, request)
    }

    /// Returns an array of values fetched from an SQL query.
    ///
    /// The value is decoded from the leftmost column if the `adapter` argument
    /// is nil.
    ///
    /// For example:
    ///
    /// ```swift
    /// try dbQueue.read { db in
    ///     let lastName = "O'Reilly"
    ///     let scores = try Int.fetchAll(db, literal: "SELECT score FROM player WHERE lastName = \(lastName)")
    /// }
    /// ```
    ///
    /// - parameters:
    ///     - db: A database connection.
    ///     - literal: An `SQL` literal.
    ///     - adapter: Optional RowAdapter.
    ///     - cached: Defaults to false. If true, the request reuses a cached prepared statement.
    /// - returns: An array of values.
    /// - throws: A ``DatabaseError`` whenever an SQLite error occurs.
    public static func fetchAll(
      _ db: Database,
      literal: SQL,
      adapter: RowAdapter? = nil,
      cached: Bool = false
    ) throws -> [Self] {
      let request = SQLRequest(literal: literal, adapter: adapter, cached: cached)
      return try Self.fetchAll(db, request)
    }

    /// Returns a set of values fetched from an SQL query.
    ///
    /// The value is decoded from the leftmost column if the `adapter` argument
    /// is nil.
    ///
    /// For example:
    ///
    /// ```swift
    /// try dbQueue.read { db in
    ///     let lastName = "O'Reilly"
    ///     let scores = try Int.fetchSet(db, literal: "SELECT score FROM player WHERE lastName = \(lastName)")
    /// }
    /// ```
    ///
    /// - parameters:
    ///     - db: A database connection.
    ///     - literal: An `SQL` literal.
    ///     - adapter: Optional RowAdapter.
    ///     - cached: Defaults to false. If true, the request reuses a cached prepared statement.
    /// - returns: A set of values.
    /// - throws: A ``DatabaseError`` whenever an SQLite error occurs.
    public static func fetchSet(
      _ db: Database,
      literal: SQL,
      adapter: RowAdapter? = nil,
      cached: Bool = false
    ) throws -> Set<Self> where Self: Hashable {
      let request = SQLRequest(literal: literal, adapter: adapter, cached: cached)
      return try Self.fetchSet(db, request)
    }

    /// Returns a cursor over values fetched from an SQL query.
    ///
    /// The value is decoded from the leftmost column if the `adapter` argument
    /// is nil.
    ///
    /// For example:
    ///
    /// ```swift
    /// try dbQueue.read { db in
    ///     let lastName = "O'Reilly"
    ///     let scoresCursor = try Int.fetchCurder(db, literal: "SELECT score FROM player WHERE lastName = \(lastName)")
    /// }
    /// ```
    ///
    /// - parameters:
    ///     - db: A database connection.
    ///     - literal: An `SQL` literal.
    ///     - adapter: Optional RowAdapter.
    ///     - cached: Defaults to false. If true, the request reuses a cached prepared statement.
    /// - returns: A `FastDatabaseCursor` over the fetched values.
    /// - throws: A ``DatabaseError`` whenever an SQLite error occurs.
    public static func fetchCursor(
      _ db: Database,
      literal: SQL,
      adapter: RowAdapter? = nil,
      cached: Bool = false
    ) throws -> FastDatabaseValueCursor<Self> {
      let request = SQLRequest(literal: literal, adapter: adapter, cached: cached)
      return try Self.fetchCursor(db, request)
    }
  }

  // MARK: - FetchableRecord

  extension FetchableRecord {
    /// Returns a single record fetched from an SQL query.
    ///
    /// For example:
    ///
    /// ```swift
    /// try dbQueue.read { db in
    ///     let lastName = "O'Reilly"
    ///     let player = try Player.fetchOne(
    ///       db,
    ///       literal: "SELECT * FROM player WHERE lastName = \(lastName) LIMIT 1"
    ///     )
    /// }
    /// ```
    /// - parameters:
    ///     - db: A database connection.
    ///     - literal: An `SQL` literal.
    ///     - adapter: Optional RowAdapter.
    ///     - cached: Defaults to false. If true, the request reuses a cached prepared statement.
    /// - returns: An optional record.
    /// - throws: A ``DatabaseError`` whenever an SQLite error occurs.
    public static func fetchOne(
      _ db: Database,
      literal: SQL,
      adapter: RowAdapter? = nil,
      cached: Bool = false
    ) throws -> Self? {
      let request = SQLRequest(literal: literal, adapter: adapter, cached: cached)
      return try Self.fetchOne(db, request)
    }

    /// Returns an array of records fetched from an SQL query.
    ///
    /// For example:
    ///
    /// ```swift
    /// try dbQueue.read { db in
    ///     let lastName = "O'Reilly"
    ///     let players = try Player.fetchAll(
    ///       db,
    ///       literal: "SELECT * FROM player WHERE lastName = \(lastName)"
    ///     )
    /// }
    /// ```
    ///
    /// - parameters:
    ///     - db: A database connection.
    ///     - literal: An `SQL` literal.
    ///     - adapter: Optional RowAdapter.
    ///     - cached: Defaults to false. If true, the request reuses a cached prepared statement.
    /// - returns: An array of records.
    /// - throws: A ``DatabaseError`` whenever an SQLite error occurs.
    public static func fetchAll(
      _ db: Database,
      literal: SQL,
      adapter: RowAdapter? = nil,
      cached: Bool = false
    ) throws -> [Self] {
      let request = SQLRequest(literal: literal, adapter: adapter, cached: cached)
      return try Self.fetchAll(db, request)
    }

    /// Returns a set of records fetched from an SQL query.
    ///
    /// For example:
    ///
    /// ```swift
    /// try dbQueue.read { db in
    ///     let lastName = "O'Reilly"
    ///     let players = try Player.fetchSet(
    ///       db,
    ///       literal: "SELECT * FROM player WHERE lastName = \(lastName)"
    ///     )
    /// }
    /// ```
    ///
    /// - parameters:
    ///     - db: A database connection.
    ///     - literal: An `SQL` literal.
    ///     - adapter: Optional RowAdapter.
    ///     - cached: Defaults to false. If true, the request reuses a cached prepared statement.
    /// - returns: A set of records.
    /// - throws: A ``DatabaseError`` whenever an SQLite error occurs.
    public static func fetchSet(
      _ db: Database,
      literal: SQL,
      adapter: RowAdapter? = nil,
      cached: Bool = false
    ) throws -> Set<Self> where Self: Hashable {
      let request = SQLRequest(literal: literal, adapter: adapter, cached: cached)
      return try Self.fetchSet(db, request)
    }

    /// Returns a cursor over records fetched from an SQL query.
    ///
    /// For example:
    ///
    /// ```swift
    /// try dbQueue.read { db in
    ///     let lastName = "O'Reilly"
    ///     let players = try Player.fetchCursor(
    ///       db,
    ///       literal: "SELECT * FROM player WHERE lastName = \(lastName)"
    ///     )
    /// }
    /// ```
    ///
    /// - parameters:
    ///     - db: A database connection.
    ///     - literal: An `SQL` literal.
    ///     - adapter: Optional RowAdapter.
    ///     - cached: Defaults to false. If true, the request reuses a cached prepared statement.
    /// - returns: A `RecordCursor` over fetched values.
    /// - throws: A ``DatabaseError`` whenever an SQLite error occurs.
    public static func fetchCursor(
      _ db: Database,
      literal: SQL,
      adapter: RowAdapter? = nil,
      cached: Bool = false
    ) throws -> RecordCursor<Self> {
      let request = SQLRequest(literal: literal, adapter: adapter, cached: cached)
      return try Self.fetchCursor(db, request)
    }
  }
#endif
