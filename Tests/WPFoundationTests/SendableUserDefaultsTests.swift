import Testing
import WPFoundation

@Suite("SendableUserDefaults tests")
struct SendableUserDefaultsTest {
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
    withKnownIssue {
      _ = self.userDefaults.values(forKey: key)
    } matching: { issue in
      issue.comments.contains(
        """
        An invalid key format was detected for SendableUserDefaults value observation:
          
          - Key: \(key)
        
        Key names which do not use the same format as swift variable names will not receive any \
        KVO updates.
        """
      )
    }
  }
}
