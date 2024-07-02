import WPSilentModeSwitch
import WPFoundation
import Testing
import CoreAudio
import Numerics

#if os(macOS)
import AudioToolbox

// MARK: - Test Suite

@Suite("CoreAudioDeviceOutputVolume tests", .serialized)
struct CoreAudioDeviceOutputVolumeTests {
  @Test("Status Updates Respond to Mute Switch Changes")
  func respondToMuteSwitchChanges() async throws {
    let silentMode = try #require(try CoreAudioDeviceOutputVolume())
    let testDecibals = 0.5
    try await setVolume(outputVolume: testDecibals)
    try await setIsMuted(false)
    let task = Task {
      try await silentMode.statusUpdates.prefix(5)
        .reduce([DeviceOutputVolumeStatus]()) { acc, status in acc + [status] }
    }
    try await setIsMuted(false)
    try await setIsMuted(true)
    try await setIsMuted(true)
    try await setIsMuted(false)
    try await setIsMuted(true)
    try await setIsMuted(false)
    let statuses = try await task.value.map(TestStatus.init(volumeStatus:))
    let expectedStatuses =  [
      DeviceOutputVolumeStatus(outputVolume: testDecibals, isMuted: false),
      DeviceOutputVolumeStatus(outputVolume: testDecibals, isMuted: true),
      DeviceOutputVolumeStatus(outputVolume: testDecibals, isMuted: false),
      DeviceOutputVolumeStatus(outputVolume: testDecibals, isMuted: true),
      DeviceOutputVolumeStatus(outputVolume: testDecibals, isMuted: false)
    ]
    .map(TestStatus.init(volumeStatus:))
    #expect(statuses == expectedStatuses)
  }
  
  @Test("Status Updates Respond to Volume Changes")
  func respondToVolumeChanges() async throws {
    let silentMode = try #require(try CoreAudioDeviceOutputVolume())
    try await setVolume(outputVolume: 1)
    try await setIsMuted(false)
    let task = Task {
      try await silentMode.statusUpdates.prefix(5)
        .reduce([DeviceOutputVolumeStatus]()) { acc, status in acc + [status] }
    }
    try await setVolume(outputVolume: 0.1)
    try await setVolume(outputVolume: 0.1)
    try await setVolume(outputVolume: 0.3)
    try await setVolume(outputVolume: 0.3)
    try await setVolume(outputVolume: 0.3)
    try await setVolume(outputVolume: 0)
    try await setVolume(outputVolume: 0.5)
    let statuses = try await task.value.map(TestStatus.init(volumeStatus:))
    let expectedStatuses =  [
      DeviceOutputVolumeStatus(outputVolume: 1, isMuted: false),
      DeviceOutputVolumeStatus(outputVolume: 0.1, isMuted: false),
      DeviceOutputVolumeStatus(outputVolume: 0.3, isMuted: false),
      DeviceOutputVolumeStatus(outputVolume: 0, isMuted: false),
      DeviceOutputVolumeStatus(outputVolume: 0.5, isMuted: false)
    ]
    .map(TestStatus.init(volumeStatus:))
    #expect(statuses == expectedStatuses)
  }
}

// MARK: - TestStatus

struct TestStatus {
  let volumeStatus: DeviceOutputVolumeStatus
}

extension TestStatus: Equatable {
  static func == (lhs: Self, rhs: Self) -> Bool {
    let isApproximatelyEqual = lhs.volumeStatus.outputVolume.isApproximatelyEqual(
      to: rhs.volumeStatus.outputVolume,
      relativeTolerance: 0.0001
    )
    return lhs.volumeStatus.isMuted == rhs.volumeStatus.isMuted && isApproximatelyEqual
  }
}

// MARK: - Volume Manipulation

private func setVolume(outputVolume: Double) async throws {
  var outputVolume = Float(outputVolume)
  let deviceId = try #require(try _defaultOutputDeviceId())
  try withUnsafePointer(to: _volumePropertyAddress) {
    let status = AudioObjectSetPropertyData(
      deviceId,
      $0,
      0,
      nil,
      UInt32(MemoryLayout.size(ofValue: outputVolume)),
      &outputVolume
    )
    if status != noErr {
      throw CoreAudioError(status)
    }
  }
  await yield() // NB: Ensure CoreAudio doesn't drop the update
}

private func setIsMuted(_ isMuted: Bool) async throws {
  var isMuted: UInt32 = isMuted ? 1 : 0
  let deviceId = try #require(try _defaultOutputDeviceId())
  try withUnsafePointer(to: _mutePropertyAddress) {
    let status = AudioObjectSetPropertyData(
      deviceId,
      $0,
      0,
      nil,
      UInt32(MemoryLayout.size(ofValue: isMuted)),
      &isMuted
    )
    if status != noErr {
      throw CoreAudioError(status)
    }
  }
  await yield() // NB: Ensure CoreAudio doesn't drop the update
}

private func yield() async {
  for _ in 0..<1000 { await Task.yield() }
}

#endif
