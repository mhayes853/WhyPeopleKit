import ConcurrencyExtras
import Sharing
import WPDependencies
import WPFoundation

// MARK: - Key

/// A `SharedReaderKey` which keeps a value in sync with a
/// `NotficationCenter` notification.
public struct NotificationCenterKey<Value: Sendable>: Sendable {
  private let notificationName: Notification.Name
  private let center: NotificationCenter
  private let loadValue: @Sendable (LoadContext<Value>) async throws -> Value
  private let updatedValue: @Sendable (Notification) async throws -> Value
  private let taskBox = TaskBox<Value>()

  fileprivate init(
    _ notificationName: Notification.Name,
    loadValue: @Sendable @escaping (LoadContext<Value>) async throws -> Value,
    onNotification updatedValue: @Sendable @escaping (Notification) async throws -> Value
  ) {
    @Dependency(\.notificationCenter) var center
    self.notificationName = notificationName
    self.center = center
    self.loadValue = loadValue
    self.updatedValue = updatedValue
  }
}

extension SharedReaderKey {
  /// A shared key that keeps a value in sync with a `NotificationCenter` notification.
  ///
  /// - Parameters:
  ///   - name: The name of the notification.
  ///   - value: A function to load the updated value in response to a new notification being published.
  public static func notification<Value: Sendable>(
    name: Notification.Name,
    _ value: @Sendable @escaping () async throws -> Value
  ) -> Self where Self == NotificationCenterKey<Value> {
    NotificationCenterKey(name) { _ in
      try await value()
    } onNotification: { _ in
      try await value()
    }
  }

  /// A shared key that keeps a value in sync with a `NotificationCenter` notification.
  ///
  /// - Parameters:
  ///   - name: The name of the notification.
  ///   - loadValue: A function to load the most up to date value for the key when its loaded manually.
  ///   - updatedValue: A function to load the updated value in response to a new notification being published.
  public static func notification<Value: Sendable>(
    name: Notification.Name,
    loadValue: @Sendable @escaping (LoadContext<Value>) async throws -> Value,
    onNotification updatedValue: @Sendable @escaping (Notification) async throws -> Value
  ) -> Self where Self == NotificationCenterKey<Value> {
    NotificationCenterKey(name, loadValue: loadValue, onNotification: updatedValue)
  }
}

// MARK: - ID

public struct NotificationCenterKeyID: Hashable {
  private let name: Notification.Name
  private let center: ObjectIdentifier

  fileprivate init(name: Notification.Name, center: NotificationCenter) {
    self.name = name
    self.center = ObjectIdentifier(center)
  }
}

extension NotificationCenterKey {
  public var id: NotificationCenterKeyID {
    NotificationCenterKeyID(name: self.notificationName, center: self.center)
  }
}

// MARK: - SharedReaderKey

extension NotificationCenterKey: SharedReaderKey {
  public func load(context: LoadContext<Value>, continuation: LoadContinuation<Value>) {
    self.taskBox.setTask(continuation: continuation) {
      try await self.loadValue(context)
    }
  }

  public func subscribe(
    context: LoadContext<Value>,
    subscriber: SharedSubscriber<Value>
  ) -> SharedSubscription {
    self.taskBox.setSubscriber(subscriber)
    nonisolated(unsafe) let observer = self.center.addObserver(
      forName: self.notificationName,
      object: nil,
      queue: nil
    ) { notification in
      let transfer = UnsafeTransfer(value: notification)
      subscriber.yieldLoading()
      self.taskBox.setTask { try await self.updatedValue(transfer.value) }
    }
    return SharedSubscription {
      self.taskBox.cancel()
      self.center.removeObserver(observer)
    }
  }
}

// MARK: - Helpers

private struct UnsafeTransfer<Value>: @unchecked Sendable {
  let value: Value
}

private final class TaskBox<Value>: Sendable {
  private let state = Lock<
    (
      subscriber: SharedSubscriber<Value>?,
      continuations: [LoadContinuation<Value>],
      task: Task<Void, any Error>?
    )
  >((nil, [], nil))

  deinit { self.cancel() }

  func setTask(
    continuation: LoadContinuation<Value>? = nil,
    _ task: @escaping @Sendable () async throws -> Value
  ) {
    self.state.withLock { state in
      if let continuation {
        state.continuations.append(continuation)
      }
      state.task?.cancel()
      state.task = Task {
        let result = await Result { try await task() }.map { $0 as Value? }
        try Task.checkCancellation()
        self.state.withLock { state in
          if state.continuations.isEmpty {
            state.subscriber?.yield(with: result)
          } else {
            for continuation in state.continuations {
              continuation.resume(with: result)
            }
            state.continuations = []
          }
        }
      }
    }
  }

  func setSubscriber(_ subscriber: SharedSubscriber<Value>) {
    self.state.withLock { $0.subscriber = subscriber }
  }

  func cancel() {
    self.state.withLock { $0.task?.cancel() }
  }
}

// MARK: - CKAccountStatus Key

#if canImport(CloudKit)
  import CloudKit

  /// A dependency that loads the current `CKAccountStatus`.
  public struct CurrentCKAccountStatus: Sendable {
    private let status: @Sendable () async throws -> CKAccountStatus

    public init(status: @escaping @Sendable () async throws -> CKAccountStatus) {
      self.status = status
    }
  }

  extension CurrentCKAccountStatus {
    public init(container: CKContainer) {
      self.status = { try await container.accountStatus() }
    }
  }

  extension CurrentCKAccountStatus {
    public func callAsFunction() async throws -> CKAccountStatus {
      try await self.status()
    }
  }

  extension CurrentCKAccountStatus: DependencyKey {
    public static var liveValue: Self {
      Self(container: .default())
    }
  }

  extension DependencyValues {
    /// A dependency that loads the current `CKAccountStatus`.
    public var ckAccountStatus: CurrentCKAccountStatus {
      get { self[CurrentCKAccountStatus.self] }
      set { self[CurrentCKAccountStatus.self] = newValue }
    }
  }

  extension SharedReaderKey
  where Self == NotificationCenterKey<CKAccountStatus>.Default {
    /// A shared key for the current `CKAccountStatus`.
    ///
    /// You can override how the value is loaded by overriding the `ckAccountStatus` dependency.
    ///
    /// ```swift
    /// @Test("Status")
    /// func status()  {
    ///   withDependencies {
    ///     // Mock the status to always be noAccount
    ///     $0.ckAccountStatus = CurrentCKAccountStatus { .noAccount }
    ///   } operation: {
    ///     @SharedReader(.ckAccountStatus) var status
    ///     // Assertions...
    ///   }
    /// }
    /// ```
    public static var ckAccountStatus: Self {
      @Dependency(\.ckAccountStatus) var status
      return Self[
        .notification(name: .CKAccountChanged) { try await status() },
        default: .couldNotDetermine
      ]
    }
  }
#endif

// MARK: - LowPowerMode Key

#if !os(Linux)
  /// A dependency that detects whether or not the device is in low power mode.
  public struct IsInLowPowerMode: Sendable {
    private let isInLowPowerMode: @Sendable () -> Bool

    public init(_ isInLowPowerMode: @Sendable @escaping () -> Bool) {
      self.isInLowPowerMode = isInLowPowerMode
    }
  }

  extension IsInLowPowerMode {
    public func callAsFunction() -> Bool {
      self.isInLowPowerMode()
    }
  }

  @available(iOS 9, macOS 12, tvOS 9, watchOS 2, *)
  extension IsInLowPowerMode: DependencyKey {
    public static var liveValue: Self {
      Self { ProcessInfo.processInfo.isLowPowerModeEnabled }
    }
  }

  extension DependencyValues {
    /// A dependency that detects whether or not the device is in low power mode.
    @available(iOS 9, macOS 12, tvOS 9, watchOS 2, *)
    public var isInLowPowerMode: IsInLowPowerMode {
      get { self[IsInLowPowerMode.self] }
      set { self[IsInLowPowerMode.self] = newValue }
    }
  }

  extension SharedReaderKey
  where Self == NotificationCenterKey<Bool>.Default {
    /// A shared key that indicates whether or not the device is in low power mode.
    ///
    /// You can override how the value is detected by overriding the `isInLowPowerMode` dependency.
    ///
    /// ```swift
    /// @Test("Low Power")
    /// func lowPower()  {
    ///   withDependencies {
    ///     // Mock the mode to always be in low power mode
    ///     $0.isInLowPowerMode = IsInLowPowerMode { true }
    ///   } operation: {
    ///     @SharedReader(.isInLowPowerMode) var isInLowPowerMode
    ///     // Assertions...
    ///   }
    /// }
    /// ```
    @available(iOS 9, macOS 12, tvOS 9, watchOS 2, *)
    public static var isInLowPowerMode: Self {
      @Dependency(\.isInLowPowerMode) var isLowPower
      return Self[
        .notification(name: .NSProcessInfoPowerStateDidChange) { isLowPower() },
        default: false
      ]
    }
  }
#endif
