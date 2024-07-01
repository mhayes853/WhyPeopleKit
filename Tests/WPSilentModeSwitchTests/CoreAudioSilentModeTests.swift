import WPSilentModeSwitch
import WPFoundation
import Testing
import CoreAudio

#if os(macOS)
import AudioToolbox

@Suite("CoreAudioSilentMode tests")
struct CoreAudioSilentModeTests {
  @Test("Status Updates Respond to Mute Switch Changes")
  func respondToMuteSwitchChanges() async throws {
    let silentMode = try #require(try CoreAudioSilentMode())
    try setIsMuted(false)
    let task = Task {
      try await silentMode.statusUpdates.prefix(5)
        .reduce([SilentModeStatus]()) { acc, status in acc + [status] }
    }
    try setIsMuted(false)
    try setIsMuted(true)
    try setIsMuted(true)
    try setIsMuted(false)
    try setIsMuted(true)
    try setIsMuted(false)
    let statuses = try await task.value
    #expect(statuses == [.hasVolume, .noVolume, .hasVolume, .noVolume, .hasVolume])
  }
}

private func setIsMuted(_ isMuted: Bool) throws {
  var isMuted: UInt32 = isMuted ? 1 : 0
  let deviceId = try #require(try _defaultOutputDeviceId())
  var address = AudioObjectPropertyAddress(
    mSelector: kAudioDevicePropertyMute,
    mScope: kAudioDevicePropertyScopeOutput,
    mElement: kAudioObjectPropertyElementMain
  )
  let status = AudioObjectSetPropertyData(
    deviceId,
    &address,
    0,
    nil,
    UInt32(MemoryLayout.size(ofValue: isMuted)),
    &isMuted
  )
  
  if status != noErr {
    throw CoreAudioError(status)
  }
}

#endif
