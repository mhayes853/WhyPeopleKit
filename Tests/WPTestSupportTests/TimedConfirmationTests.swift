import Testing
import Foundation
import WPTestSupport

@Suite("TimedConfirmation tests")
struct TimedConfirmationTests {
  @Test("Waits for Confirmation To Be Confirmed From Synchronous Function Call")
  func waitsForConfirmation() async {
    await timedConfirmation(expectedCount: 3) { confirm in
      let observer = NotificationCenter.default.addObserver(
        forName: testNotification,
        object: nil,
        queue: nil
      ) { _ in confirm() }
      NotificationCenter.default.post(name: testNotification, object: nil)
      NotificationCenter.default.post(name: testNotification, object: nil)
      NotificationCenter.default.post(name: testNotification, object: nil)
      NotificationCenter.default.removeObserver(observer)
    }
  }
  
  @Test("Raises Issue After Timeout")
  func raisesTimeoutIssue() async {
    let clock = ContinuousClock()
    let time = await clock.measure {
      await withKnownIssue {
        await timedConfirmation(expectedCount: 3, timeout: .milliseconds(200)) { confirm in
          let observer = NotificationCenter.default.addObserver(
            forName: testNotification,
            object: nil,
            queue: nil
          ) { _ in confirm() }
          NotificationCenter.default.post(name: testNotification, object: nil)
          NotificationCenter.default.post(name: testNotification, object: nil)
          NotificationCenter.default.removeObserver(observer)
        }
      }
    }
    let expectedTimeRange = Duration.milliseconds(150)...Duration.milliseconds(250)
    #expect(expectedTimeRange.contains(time))
  }
  
  @Test("Raises Issue After Timeout, When Body Runs Longer Than Timeout")
  func raisesTimeoutIssueOnLongBody() async {
    let clock = ContinuousClock()
    let time = await clock.measure {
      await withKnownIssue {
        await timedConfirmation(expectedCount: 3) { confirm in
          let observer = NotificationCenter.default.addObserver(
            forName: testNotification,
            object: nil,
            queue: nil
          ) { _ in confirm() }
          NotificationCenter.default.post(name: testNotification, object: nil)
          NotificationCenter.default.post(name: testNotification, object: nil)
          try? await Task.sleep(for: .seconds(5))
          NotificationCenter.default.removeObserver(observer)
        }
      }
    }
    #expect(time < .seconds(1))
  }
}

private let testNotification = Notification.Name("TimedConfirmationTestsNotification")
