import Testing
import WPFoundation
import WPTestSupport

@Suite("SendableUserDefaults tests")
struct SendableUserDefaultsTests {
  private let userDefaults: SendableUserDefaults

  init() {
    let suiteName = "wp.foundation.test"
    self.userDefaults = SendableUserDefaults(suiteName: suiteName)!
    self.userDefaults.removePersistentDomain(forName: suiteName)
  }

  @Test(
    "Observes new values based on key",
    arguments: ["test", "helloWorld", "hello_world", "_helloWorld"]
  )
  func observeNew(key: String) async throws {
    let values = self.userDefaults.values(forKey: key)
    var iterator = values.makeAsyncIterator()
    var value = await iterator.next()
    #expect(try #require(value) == nil)

    self.userDefaults.set("blob", forKey: key)
    self.userDefaults.set(1, forKey: key)

    value = await iterator.next()
    #expect(try #require(value as? String) == "blob")

    value = await iterator.next()
    #expect(try #require(value as? Int) == 1)
  }

  @Test(
    "Raises issue when using an invalid key format",
    arguments: ["hello.world", "hello world", "123key"]
  )
  func observeNewInvalidFormat(key: String) async throws {
    withExpectedIssue {
      _ = self.userDefaults.values(forKey: key)
    }

    withExpectedIssue {
      let observation = self.userDefaults.observeValue(forKey: key) { _ in }
      self.userDefaults.removeObservation(observation)
    }
  }
}
