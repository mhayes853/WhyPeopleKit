#if canImport(WPGRDB)
  import WPGRDB
  import Dependencies

  // MARK: - AsyncInitializedDatabaseWriter

  /// A protocol for managing the asynchrnous initialization of a GRDB `DatabaseWriter`.
  ///
  /// To utilize the async database initialization in your app, create a database wrapper class for
  /// your app that creates a `DatabaseWriter` in the backgound.
  ///
  /// ```swift
  /// class AppDatabase: AsyncInitializedDatabaseWriter {
  ///   private let task: Task<any DatabaseWriter, any Error>
  ///
  ///   var writer: any DatabaseWriter {
  ///     get async throws { try await task.value }
  ///   }
  ///
  ///   init(/* ... */) {
  ///     self.task = Task {
  ///       try DatabasePool(/* ... */)
  ///     }
  ///   }
  /// }
  /// ```
  public protocol AsyncInitializedDatabaseWriter: Sendable {
    /// The initialized `DatabaseWriter` retrieved asynchronously.
    var writer: any DatabaseWriter { get async throws }
  }

  // MARK: - ConstantInitializedDatabaseWriter

  /// An ``AsyncInitializedDatabaseWriter`` that contains a pre-initialized `DatabaseWriter`.
  ///
  /// This is primarily useful for testing or SwiftUI previews, where async initialization is not
  /// necessary.
  public struct ConstantInitializedDatabaseWriter: AsyncInitializedDatabaseWriter {
    public let writer: any DatabaseWriter
  }

  extension AsyncInitializedDatabaseWriter where Self == ConstantInitializedDatabaseWriter {
    /// An ``AsyncInitializedDatabaseWriter`` that contains a pre-initialized `DatabaseWriter`.
    ///
    /// This is primarily useful for testing or SwiftUI previews, where async initialization is not
    /// necessary.
    public static func constant(_ writer: some DatabaseWriter) -> Self {
      ConstantInitializedDatabaseWriter(writer: writer)
    }
  }

  // MARK: - DependencyValues

  extension DependencyValues {
    /// The default asynchronous database used by the shared keys in `WPGRDBSharing`.
    public var defaultAsyncDatabase: any AsyncInitializedDatabaseWriter {
      get { self[DefaultAsyncInitializedDatabaseWriterKey.self] }
      set { self[DefaultAsyncInitializedDatabaseWriterKey.self] = newValue }
    }

    private enum DefaultAsyncInitializedDatabaseWriterKey: DependencyKey {
      static var liveValue: any AsyncInitializedDatabaseWriter { testValue }
      static var testValue: any AsyncInitializedDatabaseWriter {
        var message: String {
          @Dependency(\.context) var context
          switch context {
          case .live:
            return """
              A blank, in-memory database is being used. To set the async database that is used by \
              'WPSharingGRDB', use the 'prepareDependencies' tool as early as possible in the lifetime \
              of your app, such as in your app or scene delegate in UIKit, or the app entry point in \
              SwiftUI alongside a custom `AppDatabase` class to initialize the database asynchrnously.

                  class AppDatabase: AsyncInitializedDatabaseWriter {
                    private let task: Task<any DatabaseWriter, any Error>

                    var writer: any DatabaseWriter {
                      get async throws { try await task.value }
                    }

                    init(/* ... */) {
                      self.task = Task {
                        try DatabasePool(/* ... */)
                      }
                    }
                  }

                  @main
                  struct MyApp: App {
                    init() {
                      prepareDependencies {
                        $0.defaultAsyncDatabase = AppDatabase(/* ... */)
                      }
                    }

                    // ...
                  }
              """

          case .preview:
            return """
              A blank, in-memory database is being used. To set the async database that is used by \
              'WPSharingGRDB' in a preview, use a tool like the 'dependency' trait:

                  #Preview(
                    traits: .dependency(\\.defaultAsyncDatabase, try .constant(DatabaseQueue(/* ... */)))
                  ) {
                    // ...
                  }
              """

          case .test:
            return """
              A blank, in-memory database is being used. To set the async database that is used by \
              'WPSharingGRDB' in a test, use a tool like the 'dependency' trait from \
              'DependenciesTestSupport':

                  import DependenciesTestSupport

                  @Suite(.dependency(\\.defaultAsyncDatabase, try .constant(DatabaseQueue(/* ... */))))
                  struct MyTests {
                    // ...
                  }
              """
          }
        }
        if shouldReportUnimplemented {
          reportIssue(message)
        }
        var configuration = Configuration()
        #if DEBUG
          configuration.label = "co.pointfree.SharingGRDB.testValue"
        #endif
        return try! .constant(DatabaseQueue(configuration: configuration))
      }
    }
  }
#endif
