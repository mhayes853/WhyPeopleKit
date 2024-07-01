import WPSilentModeSwitch
import WPFoundation
import Testing
import CoreAudio
import Numerics

#if os(macOS)
import AudioToolbox

// MARK: - Test Suite

@Suite("CoreAudioDeviceVolume tests", .serialized)
struct CoreAudioDeviceVolumeTests {
  @Test("Status Updates Respond to Mute Switch Changes")
  func respondToMuteSwitchChanges() async throws {
    let silentMode = try #require(try CoreAudioDeviceVolume())
    let testDecibals = 0.5
    try await setVolume(decibals: testDecibals)
    try await setIsMuted(false)
    let task = Task {
      try await silentMode.statusUpdates.prefix(5)
        .reduce([DeviceVolumeStatus]()) { acc, status in acc + [status] }
    }
    try await setIsMuted(false)
    try await setIsMuted(true)
    try await setIsMuted(true)
    try await setIsMuted(false)
    try await setIsMuted(true)
    try await setIsMuted(false)
    let statuses = try await task.value.map(TestStatus.init(volumeStatus:))
    let expectedStatuses =  [
      DeviceVolumeStatus(decibals: testDecibals, isMuted: false),
      DeviceVolumeStatus(decibals: testDecibals, isMuted: true),
      DeviceVolumeStatus(decibals: testDecibals, isMuted: false),
      DeviceVolumeStatus(decibals: testDecibals, isMuted: true),
      DeviceVolumeStatus(decibals: testDecibals, isMuted: false)
    ]
    .map(TestStatus.init(volumeStatus:))
    #expect(statuses == expectedStatuses)
  }
  
  @Test("Status Updates Respond to Volume Changes")
  func respondToVolumeChanges() async throws {
    let silentMode = try #require(try CoreAudioDeviceVolume())
    try await setVolume(decibals: 1)
    try await setIsMuted(false)
    let task = Task {
      try await silentMode.statusUpdates.prefix(5)
        .reduce([DeviceVolumeStatus]()) { acc, status in acc + [status] }
    }
    try await setVolume(decibals: 0.1)
    try await setVolume(decibals: 0.1)
    try await setVolume(decibals: 0.3)
    try await setVolume(decibals: 0.3)
    try await setVolume(decibals: 0.3)
    try await setVolume(decibals: 0)
    try await setVolume(decibals: 0.5)
    let statuses = try await task.value.map(TestStatus.init(volumeStatus:))
    let expectedStatuses =  [
      DeviceVolumeStatus(decibals: 1, isMuted: false),
      DeviceVolumeStatus(decibals: 0.1, isMuted: false),
      DeviceVolumeStatus(decibals: 0.3, isMuted: false),
      DeviceVolumeStatus(decibals: 0, isMuted: false),
      DeviceVolumeStatus(decibals: 0.5, isMuted: false)
    ]
    .map(TestStatus.init(volumeStatus:))
    #expect(statuses == expectedStatuses)
  }
}

// MARK: - TestStatus

struct TestStatus {
  let volumeStatus: DeviceVolumeStatus
}

extension TestStatus: Equatable {
  static func == (lhs: Self, rhs: Self) -> Bool {
    let isApproximatelyEqual = lhs.volumeStatus.decibals.isApproximatelyEqual(
      to: rhs.volumeStatus.decibals,
      relativeTolerance: 0.0001
    )
    return lhs.volumeStatus.isMuted == rhs.volumeStatus.isMuted && isApproximatelyEqual
  }
}

// MARK: - Volume Manipulation

private func setVolume(decibals: Double) async throws {
  var decibals = Float(decibals)
  let deviceId = try #require(try _defaultOutputDeviceId())
  try withUnsafePointer(to: _volumePropertyAddress) {
    let status = AudioObjectSetPropertyData(
      deviceId,
      $0,
      0,
      nil,
      UInt32(MemoryLayout.size(ofValue: decibals)),
      &decibals
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
