@testable import WPSilentModeSwitch
import Clocks
import Testing

#if !os(watchOS)

@Suite("DeviceOutputVolume+PingForMuteStatus tests")
struct DeviceOutputVolumePingForMuteStatusTests {
  @Test("Is Muted When Ping Finishes Under the Threshold")
  func muteStatus() async throws {
    let clock = TestClock()
    let sleepTime = SleepTime(duration: .milliseconds(250))
    let deviceVolume = TestDeviceVolume(statusUpdates: AsyncThrowingStream { _ in })
      .pingForMuteStatus(
        interval: .seconds(1),
        threshold: .milliseconds(200),
        clock: clock,
        ping: { try? await clock.sleep(for: sleepTime.duration) }
      )
    let task = Task {
      try await deviceVolume.statusUpdates.prefix(3).reduce([Bool]()) { acc, status in
        acc + [status.isMuted]
      }
    }
    await clock.advance(by: .milliseconds(250))
    await sleepTime.setDuration(.milliseconds(150))
    await clock.advance(by: .seconds(1))
    await clock.advance(by: .milliseconds(150))
    await clock.advance(by: .seconds(1))
    await clock.advance(by: .milliseconds(150))
    await sleepTime.setDuration(.milliseconds(250))
    await clock.advance(by: .seconds(1))
    await clock.advance(by: .milliseconds(250))
    let results = try await task.value
    #expect(results == [false, true, false])
  }
  
  @Test("Merges Updates From Base Sequence With Is Muted From Ping, and Decibals From Base")
  func merges() async throws {
    let clock = TestClock()
    let sleepTime = SleepTime(duration: .milliseconds(100))
    let (stream, continuation) = AsyncThrowingStream<DeviceOutputVolumeStatus, Error>.makeStream()
    let deviceVolume = TestDeviceVolume(statusUpdates: stream)
      .pingForMuteStatus(
        interval: .seconds(1),
        threshold: .milliseconds(200),
        clock: clock,
        ping: { try? await clock.sleep(for: sleepTime.duration) }
      )
    let task = Task {
      try await deviceVolume.statusUpdates.prefix(4)
        .reduce([DeviceOutputVolumeStatus]()) { acc, status in acc + [status] }
    }
    continuation.yield(DeviceOutputVolumeStatus(outputVolume: 0.7, isMuted: false))
    await clock.advance(by: .milliseconds(100))
    await clock.advance(by: .seconds(1))
    await clock.advance(by: .milliseconds(100))
    await sleepTime.setDuration(.milliseconds(300))
    continuation.yield(DeviceOutputVolumeStatus(outputVolume: 0.5, isMuted: true))
    await clock.advance(by: .seconds(1))
    await clock.advance(by: .milliseconds(300))
    let statuses = try await task.value
    let expectedStatuses = [
      DeviceOutputVolumeStatus(outputVolume: 0.7, isMuted: false),
      DeviceOutputVolumeStatus(outputVolume: 0.7, isMuted: true),
      DeviceOutputVolumeStatus(outputVolume: 0.5, isMuted: true),
      DeviceOutputVolumeStatus(outputVolume: 0.5, isMuted: false)
    ]
    #expect(statuses == expectedStatuses)
  }
  
  @Test("Forwards Error From Base Volume")
  func forwardsBaseError() async throws {
    let (stream, continuation) = AsyncThrowingStream<DeviceOutputVolumeStatus, Error>.makeStream()
    let deviceVolume = TestDeviceVolume(statusUpdates: stream)
      .pingForMuteStatus(
        interval: .seconds(1),
        threshold: .milliseconds(200),
        clock: TestClock(),
        ping: {}
      )
    let task = Task {
      try await deviceVolume.statusUpdates
        .reduce([DeviceOutputVolumeStatus]()) { acc, status in acc + [status] }
    }
    struct SomeError: Error {}
    continuation.finish(throwing: SomeError())
    await #expect(throws: SomeError.self) {
      try await task.value
    }
  }
}

private actor SleepTime {
  var duration: Duration
  
  init(duration: Duration) {
    self.duration = duration
  }
  
  func setDuration(_ duration: Duration) {
    self.duration = duration
  }
}

private struct TestDeviceVolume: DeviceOutputVolume {
  let statusUpdates: AsyncThrowingStream<DeviceOutputVolumeStatus, Error>
}

#endif
