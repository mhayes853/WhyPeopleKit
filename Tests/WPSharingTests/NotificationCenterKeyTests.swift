import ConcurrencyExtras
import WPSharing
import XCTest

final class NotificationCenterKeyTests: XCTestCase, @unchecked Sendable {
  private let expectedInitialValue = 1
  private let expectedValueAfterPublish = 2
  private let notification = Notification.Name("NotificationCenterKeyTest")

  func testLoadsInitialState() async {
    @SharedReader(self.testKey()) var state = 0
    await waitForNoDifference(state, self.expectedInitialValue)
  }

  func testReloadsBasedOnNotificationSent() async {
    @SharedReader(self.testKey()) var state = 0
    NotificationCenter.default.post(name: self.notification, object: nil)
    await waitForNoDifference(state, self.expectedValueAfterPublish)
  }

  func testCancellation_StopsObservingNotifications() async {
    let key = self.testKey()
    let lockedExpectation = LockIsolated<XCTestExpectation>(
      self.expectation(description: "publishes first value")
    )
    let subscription = key.subscribe(initialValue: nil) { _ in
      lockedExpectation.value.fulfill()
    }
    await self.fulfillment(of: [lockedExpectation.value])
    subscription.cancel()
    let e = self.expectation(description: "does not publish again")
    e.isInverted = true
    lockedExpectation.setValue(e)
    NotificationCenter.default.post(
      name: self.notification,
      object: nil
    )
    await self.fulfillment(of: [lockedExpectation.value], timeout: 0.1)
  }

  private func testKey() -> some SharedReaderKey<Int> {
    .notification(name: self.notification) { @Sendable _ in
      self.expectedInitialValue
    } onNotification: { @Sendable _ in
      self.expectedValueAfterPublish
    }
  }
}

private func waitForNoDifference<T: Equatable>(
  _ value: @autoclosure () async -> T,
  _ expectedValue: @autoclosure () async -> T
) async {
  repeat {
    let values = await (value(), expectedValue())
    if values.0 == values.1 {
      break
    }
    await Task.yield()
  } while true
}
