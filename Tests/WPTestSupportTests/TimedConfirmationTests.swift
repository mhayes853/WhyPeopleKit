import Foundation
import Testing
import WPTestSupport

@Suite("TimedConfirmation tests")
struct TimedConfirmationTests {
  private let notificationCenter = NotificationCenter()

  @Test("Waits for Confirmation To Be Confirmed From Synchronous Function Call")
  func waitsForConfirmation() async {
    await timedConfirmation(expectedCount: 3) { confirm in
      let observer = self.notificationCenter.addObserver(
        forName: testNotification,
        object: nil,
        queue: nil
      ) { _ in confirm() }
      self.notificationCenter.post(name: testNotification, object: nil)
      self.notificationCenter.post(name: testNotification, object: nil)
      self.notificationCenter.post(name: testNotification, object: nil)
      self.notificationCenter.removeObserver(observer)
    }
  }

  @Test("Raises Issue After Timeout")
  func raisesTimeoutIssue() async {
    let clock = ContinuousClock()
    let time = await clock.measure {
      await withKnownIssue {
        await timedConfirmation(expectedCount: 3, timeout: .milliseconds(200)) { confirm in
          let observer = self.notificationCenter.addObserver(
            forName: testNotification,
            object: nil,
            queue: nil
          ) { _ in confirm() }
          self.notificationCenter.post(name: testNotification, object: nil)
          self.notificationCenter.post(name: testNotification, object: nil)
          self.notificationCenter.removeObserver(observer)
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
          let observer = self.notificationCenter.addObserver(
            forName: testNotification,
            object: nil,
            queue: nil
          ) { _ in confirm() }
          self.notificationCenter.post(name: testNotification, object: nil)
          self.notificationCenter.post(name: testNotification, object: nil)
          try? await Task.sleep(for: .seconds(5))
          self.notificationCenter.removeObserver(observer)
        }
      }
    }
    #expect(time < .seconds(1))
  }

  @Test("Raises Issue After Confirming More than Expected Count")
  func raisesIssueOnOverconfirm() async {
    await withKnownIssue {
      await timedConfirmation(expectedCount: 0) { confirm in
        let observer = self.notificationCenter.addObserver(
          forName: testNotification,
          object: nil,
          queue: nil
        ) { _ in confirm() }
        self.notificationCenter.post(name: testNotification, object: nil)
        self.notificationCenter.post(name: testNotification, object: nil)
        self.notificationCenter.removeObserver(observer)
      }
    }
  }
}

private let testNotification = Notification.Name("TimedConfirmationTestsNotification")
