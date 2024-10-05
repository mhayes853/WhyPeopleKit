import WPPerception
import Testing

@Suite("ObservedValue tests")
struct ObservedValueTests {
  @Test("Observation, Does Not Change when Changing Unrelated Property")
  func doesNotChange() async throws {
    let model = ObservedValue(Preferences())
    await confirmation(expectedCount: 0) { confirm in
      withPerceptionTracking {
        _ = model.likeCounter
      } onChange: {
        confirm()
      }
      model.inAppSafariUseReaderMode = true
    }
  }
  
  @Test("Observation, Changes when Changing Related Property")
  func changes() async throws {
    let model = ObservedValue(Preferences())
    await confirmation { confirm in
      withPerceptionTracking {
        _ = model.inAppSafariUseReaderMode
      } onChange: {
        confirm()
      }
      model.inAppSafariUseReaderMode.toggle()
    }
  }
  
  @Test("Observation, Whole Value When Changing Single Property")
  func changesWholeValue() async throws {
    let model = ObservedValue(Preferences())
    await confirmation { confirm in
      withPerceptionTracking {
        _ = model.value
      } onChange: {
        confirm()
      }
      model.likeCounter += 1
    }
  }
  
  @Test("Observation, Reset Preferences Observes Change")
  func changesReset() async throws {
    let model = ObservedValue(Preferences(likeCounter: 100))
    await confirmation { confirm in
      withPerceptionTracking {
        _ = model.value.likeCounter
      } onChange: {
        confirm()
      }
      model.value = Preferences()
    }
  }
  
  @Test("Observation, Assign Value, Updates Individual Value")
  func updatesIndividualValue() async throws {
    let model = ObservedValue(Preferences(likeCounter: 100))
    await confirmation { confirm in
      withPerceptionTracking {
        _ = model.likeCounter
      } onChange: {
        confirm()
      }
      model.value = Preferences()
    }
  }
}

private struct Preferences: Hashable, Sendable, ObservableValue {
  var likeCounter = 0
  var inAppSafariUseReaderMode = false
  var isLiveTextAnalysisEnabled = true
  var isHapticFeedbackEnabled = true
  var isHapticAudioEnabled = true
  var isBiometricUnlockEnabled = true
  var shouldLaunchWithOpenIdeasStack = true
}
