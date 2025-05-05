import ConcurrencyExtras
import CustomDump
import WPDependencies
import WPFoundation
import WPSharing
import XCTest

final class NotificationCenterKeyTests: XCTestCase, @unchecked Sendable {
  private let expectedInitialValue = 1
  private let expectedValueAfterPublish = 2
  private let notification = Notification.Name("NotificationCenterKeyTest")
  private let center = NotificationCenter()

  override func invokeTest() {
    withDependencies {
      $0.notificationCenter = self.center
    } operation: {
      super.invokeTest()
    }
  }

  func testLoadsInitialState() async {
    @SharedReader(self.testInitialLoadKey()) var state = 0
    let expectation = self.expectation(description: "observes value")
    await self.expectValueAfterNotificationPosted(
      $state,
      value: self.expectedInitialValue,
      expectation: expectation
    )
  }

  func testLoadsSubscribedStateFirstIfSubscribedStateLoadsFirst() async {
    let key = NotificationCenterKey<Int>
      .notification(name: self.notification) { @Sendable _ in
        try await Task.never()
        return self.expectedInitialValue
      } onNotification: { @Sendable _ in
        self.expectedValueAfterPublish
      }
    @SharedReader(key) var state = 0
    let expectation = self.expectation(description: "observes value")
    await self.expectValueAfterNotificationPosted(
      $state,
      value: self.expectedValueAfterPublish,
      expectation: expectation
    )

    let expectation2 = self.expectation(description: "does not observe initial value")
    expectation2.isInverted = true
    await self.expectValueAfterNotificationPosted(
      $state,
      value: self.expectedInitialValue,
      expectation: expectation2
    )
  }

  func testIsLoadingWhenUpdatingValue() async {
    let expectation = self.expectation(description: "begins loading")
    let key = NotificationCenterKey<Int>
      .notification(name: self.notification) { @Sendable _ in
        self.expectedInitialValue
      } onNotification: { @Sendable _ in
        expectation.fulfill()
        try await Task.never()
        return self.expectedValueAfterPublish
      }
    @SharedReader(key) var state = 0
    await Task.megaYield()
    self.center.post(name: self.notification, object: nil)
    await self.fulfillment(of: [expectation], timeout: 0.1)
    expectNoDifference($state.isLoading, true)
  }

  func testCancelsInitialLoadWhenNotificationArrives() async {
    let expectation = self.expectation(description: "cancels")
    let key = NotificationCenterKey<Int>
      .notification(name: self.notification) { @Sendable _ in
        try? await Task.never()
        expectation.fulfill()
        return self.expectedInitialValue
      } onNotification: { @Sendable _ in
        self.expectedValueAfterPublish
      }
    @SharedReader(key) var state = 0
    self.center.post(name: self.notification, object: nil)
    await self.fulfillment(of: [expectation], timeout: 0.1)
  }

  func testUsesSameLoadFunctionForMultipleLoads() async {
    let channel = Channel()
    let expectation = self.expectation(description: "begins loading")
    expectation.expectedFulfillmentCount = 2
    let key = NotificationCenterKey<Int>
      .notification(name: self.notification) { @Sendable _ in
        await channel.next(expectation: expectation)
      } onNotification: { @Sendable _ in
        self.expectedValueAfterPublish
      }
    @SharedReader(key) var state = 0
    @SharedReader(key) var state2 = 0
    let reader = $state2
    Task { try await reader.load() }
    await self.fulfillment(of: [expectation], timeout: 0.1)

    let observeExpectation1 = self.expectation(description: "observes first state")
    let observeExpectation2 = self.expectation(description: "observes second state")
    await self.expectObservesValue($state, value: 20, expectation: observeExpectation1) {
      channel.send(20)
    }
    await self.expectObservesValue($state2, value: 20, expectation: observeExpectation2) {}
  }

  func testReloadsBasedOnNotificationSent() async {
    let key = self.testKey()
    @SharedReader(key) var state = 0
    let expectation = self.expectation(description: "observes value")
    await self.expectValueAfterNotificationPosted(
      $state,
      value: self.expectedValueAfterPublish,
      expectation: expectation
    )
  }

  func testCancellation_StopsObservingNotifications() async {
    let key = CancellableKey(base: self.testKey())
    @SharedReader(key) var state = 0

    key.cancel()
    let expectation = self.expectation(description: "does not publish updated value")
    expectation.isInverted = true
    await self.expectValueAfterNotificationPosted(
      $state,
      value: self.expectedValueAfterPublish,
      expectation: expectation
    )
  }

  func testCancellation_CancelsLoadTask() async {
    let expectation = self.expectation(description: "cancels")
    expectation.expectedFulfillmentCount = 2
    let baseKey = NotificationCenterKey<Int>
      .notification(name: self.notification) {
        try? await Task.never()
        expectation.fulfill()
        return 1
      }
    let key = CancellableKey(base: baseKey)
    @SharedReader(key) var state = 0

    self.center.post(name: self.notification, object: nil)
    key.cancel()
    await self.fulfillment(of: [expectation], timeout: 0.1)
  }

  private func expectValueAfterNotificationPosted(
    _ state: SharedReader<Int>,
    value: Int,
    expectation: XCTestExpectation
  ) async {
    await self.expectObservesValue(state, value: value, expectation: expectation) {
      self.center.post(name: self.notification, object: nil)
    }
  }

  private func expectObservesValue(
    _ state: SharedReader<Int>,
    value: Int,
    expectation: XCTestExpectation,
    perform: () -> Void
  ) async {
    let didPublish = Lock(false)
    let token = state.observe { newValue in
      // NB: Prevent a "freed pointer was not the last allocation" error.
      didPublish.withLock { didFulfill in
        if newValue == value && !didFulfill {
          expectation.fulfill()
          didFulfill = true
        }
      }
    }
    perform()
    await self.fulfillment(of: [expectation], timeout: 0.1)
    token.cancel()
  }

  private func testInitialLoadKey() -> some SharedReaderKey<Int> {
    .notification(name: self.notification) { @Sendable _ in
      self.expectedInitialValue
    } onNotification: { @Sendable _ in
      try await Task.never()
    }
  }

  private func testKey() -> some SharedReaderKey<Int> {
    .notification(name: self.notification) { @Sendable _ in
      self.expectedInitialValue
    } onNotification: { @Sendable _ in
      self.expectedValueAfterPublish
    }
  }
}

private final class Channel: Sendable {
  private let subscribers = Lock([@Sendable (Int) -> Void]())

  func next(expectation: XCTestExpectation) async -> Int {
    await withUnsafeContinuation { continuation in
      self.subscribers.withLock { subs in
        subs.append { continuation.resume(returning: $0) }
        expectation.fulfill()
      }
    }
  }

  func send(_ value: Int) {
    self.subscribers.withLock {
      for sub in $0 {
        sub(value)
      }
      $0 = []
    }
  }
}

final class CancellableKey<Value: Sendable, Base: SharedReaderKey>: SharedReaderKey
where Base.Value == Value {
  private let base: Base
  private let subscription = LockIsolated<SharedSubscription?>(nil)

  init(base: Base) {
    self.base = base
  }

  struct ID: Hashable {
    let inner: Base.ID
  }

  var id: ID {
    ID(inner: self.base.id)
  }

  func cancel() {
    self.subscription.withValue {
      $0?.cancel()
      $0 = nil
    }
  }

  func load(context: LoadContext<Value>, continuation: LoadContinuation<Value>) {
    self.base.load(context: context, continuation: continuation)
  }

  func subscribe(
    context: LoadContext<Value>,
    subscriber: SharedSubscriber<Value>
  ) -> SharedSubscription {
    self.subscription.withValue {
      $0 = self.base.subscribe(context: context, subscriber: subscriber)
    }
    return SharedSubscription { self.cancel() }
  }
}
