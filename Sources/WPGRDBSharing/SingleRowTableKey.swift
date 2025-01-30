#if canImport(WPGRDB)
  import SwiftUI
  import WPDependencies
  import WPFoundation
  import WPGRDB
  import WPSharing

  // MARK: - SingleRowTableKey

  public struct SingleRowTableKey<Record: SingleRowTableRecord & Sendable>: SharedKey, Sendable {
    public typealias Value = Record
    private let writer: any DatabaseWriter
    private let scheduler: any ValueObservationScheduler

    fileprivate init(
      scheduler: any ValueObservationScheduler & Sendable,
      database: any DatabaseWriter
    ) {
      self.writer = database
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

  extension SharedKey where Value: SingleRowTableRecord & Sendable {
    public static func singleRowTableRecord(
      animation: Animation?,
      database: any DatabaseWriter
    ) -> SingleRowTableKey<Value> {
      .singleRowTableRecord(scheduler: .animation(animation), database: database)
    }

    public static func singleRowTableRecord(
      scheduler: any ValueObservationScheduler = .animation(nil),
      database: any DatabaseWriter
    ) -> SingleRowTableKey<Value> {
      SingleRowTableKey<Value>(scheduler: .async(onQueue: .main), database: database)
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
