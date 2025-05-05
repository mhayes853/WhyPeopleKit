#if canImport(WPGRDB) && canImport(SharingGRDB)
  import SwiftUI
  import WPDependencies
  import WPFoundation
  import WPGRDB
  import WPSharing
  import SharingGRDB

  // MARK: - SingleRowTableKey

  /// A `SharedKey` that loads and saves shared state to a single row table in a SQLite database.
  public struct AsyncSingleRowTableKey<
    Record: SingleRowTableRecord & Sendable
  >: SharedKey, Sendable {
    public typealias Value = Record
    private let writer: any AsyncInitializedDatabaseWriter
    private let scheduler: any ValueObservationScheduler

    fileprivate init(
      scheduler: any ValueObservationScheduler & Sendable,
      database: (any AsyncInitializedDatabaseWriter)?
    ) {
      @Dependency(\.defaultAsyncDatabase) var defaultDatabase
      self.writer = database ?? defaultDatabase
      self.scheduler = scheduler
    }

    public var id: AsyncSingleRowTableKeyID {
      AsyncSingleRowTableKeyID(writer: self.writer, type: Record.self)
    }

    public func load(
      context: LoadContext<Value>,
      continuation: LoadContinuation<Value>
    ) {
      Task {
        continuation.resume(
          with: await Result { try await self.writer.writer.read { try Record.find($0) } }
        )
      }
    }

    public func save(
      _ value: Value,
      context: SaveContext,
      continuation: SaveContinuation
    ) {
      Task {
        continuation.resume(
          with: await Result {
            try await self.writer.writer.write { db in try Record.update(db) { $0 = value } }
          }
        )
      }
    }

    public func subscribe(
      context: LoadContext<Value>,
      subscriber: SharedSubscriber<Value>
    ) -> SharedSubscription {
      let task = Task {
        do {
          let writer = try await self.writer.writer
          let cancellable = Lock<AnyDatabaseCancellable?>(nil)
          await withTaskCancellationHandler {
            cancellable.withLock {
              $0 = ValueObservation.tracking { try Record.find($0) }
                .start(in: writer, scheduling: self.scheduler) { error in
                  subscriber.yield(throwing: error)
                } onChange: { newValue in
                  subscriber.yield(newValue)
                }
            }
          } onCancel: {
            cancellable.withLock { $0?.cancel() }
          }
        } catch {
          subscriber.yield(throwing: error)
        }
      }
      return SharedSubscription { task.cancel() }
    }
  }

  extension SharedKey {
    /// A `SharedKey` that loads and saves shared state to a single row table in a SQLite database.
    ///
    /// - Parameters:
    ///   - animation: An animation to play when updating the shared value.
    ///   - database: An ``AsyncInitializedDatabaseWriter`` to use for persistence.
    /// - Returns: A shared key.
    public static func asyncSingleRowTableRecord<Value>(
      animation: Animation?,
      database: (any AsyncInitializedDatabaseWriter)? = nil
    ) -> Self where Self == AsyncSingleRowTableKey<Value> {
      .asyncSingleRowTableRecord(scheduler: .animation(animation), database: database)
    }

    /// A `SharedKey` that loads and saves shared state to a single row table in a SQLite database.
    ///
    /// - Parameters:
    ///   - scheduler: A `ValueObservation` scheduler to use.
    ///   - database: An ``AsyncInitializedDatabaseWriter`` to use for persistence.
    /// - Returns: A shared key.
    public static func asyncSingleRowTableRecord<Value>(
      scheduler: any ValueObservationScheduler = .async(onQueue: .main),
      database: (any AsyncInitializedDatabaseWriter)? = nil
    ) -> Self where Self == AsyncSingleRowTableKey<Value> {
      AsyncSingleRowTableKey<Value>(scheduler: scheduler, database: database)
    }
  }

  // MARK: - SingleRowTableKeyID

  public struct AsyncSingleRowTableKeyID: Hashable {
    private let databaseIdentifier: ObjectIdentifier
    private let recordTypeIdentifier: ObjectIdentifier

    fileprivate init<Record: SingleRowTableRecord>(
      writer: any AsyncInitializedDatabaseWriter,
      type: Record.Type
    ) {
      self.databaseIdentifier = ObjectIdentifier(writer)
      self.recordTypeIdentifier = ObjectIdentifier(type)
    }
  }
#endif
