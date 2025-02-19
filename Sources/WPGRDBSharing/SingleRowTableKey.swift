#if canImport(WPGRDB)
  import SwiftUI
  import WPDependencies
  import WPFoundation
  import WPGRDB
  import WPSharing
  import SharingGRDB

  // MARK: - SingleRowTableKey

  /// A `SharedKey` that loads and saves shared state to a single row table in a SQLite database.
  public struct SingleRowTableKey<Record: SingleRowTableRecord & Sendable>: SharedKey, Sendable {
    public typealias Value = Record
    private let writer: any DatabaseWriter
    private let scheduler: any ValueObservationScheduler

    fileprivate init(
      scheduler: any ValueObservationScheduler & Sendable,
      database: (any DatabaseWriter)?
    ) {
      @Dependency(\.defaultDatabase) var defaultDatabase
      self.writer = database ?? defaultDatabase
      self.scheduler = scheduler
    }

    public var id: SingleRowTableKeyID {
      SingleRowTableKeyID(writer: self.writer, type: Record.self)
    }

    public func load(
      context: LoadContext<Value>,
      continuation: LoadContinuation<Value>
    ) {
      continuation.resume(with: Result { try self.writer.read { try Record.find($0) } })
    }

    public func save(
      _ value: Value,
      context: SaveContext,
      continuation: SaveContinuation
    ) {
      continuation.resume(
        with: Result {
          try self.writer.write { db in try Record.update(db) { $0 = value } }
        }
      )
    }

    public func subscribe(
      context: LoadContext<Value>,
      subscriber: SharedSubscriber<Value>
    ) -> SharedSubscription {
      let cancellable = ValueObservation.tracking { try Record.find($0) }
        .start(in: self.writer, scheduling: self.scheduler) { error in
          subscriber.yield(throwing: error)
        } onChange: { newValue in
          subscriber.yield(newValue)
        }
      return SharedSubscription { cancellable.cancel() }
    }
  }

  extension SharedKey {
    /// A `SharedKey` that loads and saves shared state to a single row table in a SQLite database.
    ///
    /// - Parameters:
    ///   - animation: An animation to play when updating the shared value.
    ///   - database: A `DatabaseWriter` to use for persistence.
    /// - Returns: A shared key.
    public static func singleRowTableRecord<Value>(
      animation: Animation?,
      database: (any DatabaseWriter)? = nil
    ) -> Self where Self == SingleRowTableKey<Value> {
      .singleRowTableRecord(scheduler: .animation(animation), database: database)
    }

    /// A `SharedKey` that loads and saves shared state to a single row table in a SQLite database.
    ///
    /// - Parameters:
    ///   - scheduler: A `ValueObservation` scheduler to use.
    ///   - database: A `DatabaseWriter` to use for persistence.
    /// - Returns: A shared key.
    public static func singleRowTableRecord<Value>(
      scheduler: any ValueObservationScheduler = .async(onQueue: .main),
      database: (any DatabaseWriter)? = nil
    ) -> Self where Self == SingleRowTableKey<Value> {
      SingleRowTableKey<Value>(scheduler: scheduler, database: database)
    }
  }

  // MARK: - SingleRowTableKeyID

  public struct SingleRowTableKeyID: Hashable {
    private let databaseIdentifier: ObjectIdentifier
    private let recordTypeIdentifier: ObjectIdentifier

    fileprivate init<Record: SingleRowTableRecord>(writer: any DatabaseWriter, type: Record.Type) {
      self.databaseIdentifier = ObjectIdentifier(writer)
      self.recordTypeIdentifier = ObjectIdentifier(type)
    }
  }
#endif
