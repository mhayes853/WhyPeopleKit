#if os(iOS)
  import Clocks
  import Synchronization
  import Testing
  @_spi(Workaround) import WPDeviceVolume
  import os

  @Suite("DeviceOutputVolume+PingForMuteStatus tests")
  struct DeviceOutputVolumePingForMuteStatusTests {
    @Test("Is Muted When Ping Finishes Under the Threshold")
    @available(iOS 16, macOS 13, tvOS 16, watchOS 9, *)
    func muteStatus() async throws {
      let clock = TestClock()
      let sleepTime = SleepTime(duration: .milliseconds(250))
      let deviceVolume = NoopDeviceOutputVolume()
        .pingForMuteStatus(
          interval: .seconds(1),
          threshold: .milliseconds(200),
          clock: clock,
          ping: { try? await clock.sleep(for: sleepTime.duration) },
          isInBackground: { false }
        )
      let task = Task {
        try await deviceVolume.statusUpdates.prefix(3)
          .reduce([Bool]()) { acc, status in
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
    @available(iOS 16, macOS 13, tvOS 16, watchOS 9, *)
    func merges() async throws {
      let clock = TestClock()
      let sleepTime = SleepTime(duration: .milliseconds(100))
      let testVolume = TestDeviceOutputVolume()
      let deviceVolume = testVolume.pingForMuteStatus(
        interval: .seconds(1),
        threshold: .milliseconds(200),
        clock: clock,
        ping: { try? await clock.sleep(for: sleepTime.duration) },
        isInBackground: { false }
      )
      let task = Task {
        try await deviceVolume.statusUpdates.prefix(4)
          .reduce([DeviceOutputVolumeStatus]()) { acc, status in acc + [status] }
      }
      await testVolume.send(
        result: .success(DeviceOutputVolumeStatus(outputVolume: 0.7, isMuted: false))
      )
      await clock.advance(by: .milliseconds(100))
      await clock.advance(by: .seconds(1))
      await clock.advance(by: .milliseconds(100))
      await sleepTime.setDuration(.milliseconds(300))
      await testVolume.send(
        result: .success(DeviceOutputVolumeStatus(outputVolume: 0.5, isMuted: true))
      )
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
    @available(iOS 16, macOS 13, tvOS 16, watchOS 9, *)
    func forwardsBaseError() async throws {
      let testVolume = TestDeviceOutputVolume()
      let deviceVolume = testVolume.pingForMuteStatus(
        interval: .seconds(1),
        threshold: .milliseconds(200),
        clock: TestClock()
      )
      let task = Task {
        try await deviceVolume.statusUpdates
          .reduce([DeviceOutputVolumeStatus]()) { acc, status in acc + [status] }
      }
      struct SomeError: Error {}
      await testVolume.send(result: .failure(SomeError()))
      await #expect(throws: SomeError.self) {
        try await task.value
      }
    }

    @Test("Uses Same Ping For Multiple Subscribers")
    @available(iOS 16, macOS 13, tvOS 16, watchOS 9, *)
    func samePing() async throws {
      let clock = TestClock()
      let deviceVolume = NoopDeviceOutputVolume()
        .pingForMuteStatus(
          interval: .seconds(1),
          threshold: .milliseconds(200),
          clock: clock,
          ping: { try? await clock.sleep(for: .milliseconds(100)) },
          isInBackground: { false }
        )
      let task1 = Task {
        try await deviceVolume.statusUpdates.first(where: { _ in true })
      }
      await clock.advance(by: .milliseconds(50))
      let task2 = Task {
        try await deviceVolume.statusUpdates.first(where: { _ in true })
      }
      await clock.advance(by: .milliseconds(50))
      let (value1, value2) = try await (task1.value, task2.value)
      #expect(value1?.isMuted == true)
      #expect(value2?.isMuted == true)
    }

    @Test("Emits Current Muted Status to New Subscriber")
    @available(iOS 16, macOS 13, tvOS 16, watchOS 9, *)
    func emitsStatusToNewSubscriber() async throws {
      let clock = TestClock()
      let deviceVolume = NoopDeviceOutputVolume()
        .pingForMuteStatus(
          interval: .seconds(1),
          threshold: .milliseconds(200),
          clock: clock,
          ping: { try? await clock.sleep(for: .milliseconds(100)) },
          isInBackground: { false }
        )
      Task {
        try await deviceVolume.statusUpdates.first(where: { _ in true })
      }
      await clock.advance(by: .milliseconds(100))
      await clock.advance(by: .milliseconds(432))
      let status = try await deviceVolume.statusUpdates.first(where: { _ in true })
      #expect(status?.isMuted == true)
    }

    @Test("Stops Pinging When No More Subscribers")
    @available(iOS 16, macOS 13, tvOS 16, watchOS 9, *)
    func stopsPinging() async throws {
      let clock = TestClock()
      let pingCount = OSAllocatedUnfairLock(initialState: 0)
      let deviceVolume = NoopDeviceOutputVolume()
        .pingForMuteStatus(
          interval: .seconds(1),
          threshold: .milliseconds(200),
          clock: clock,
          ping: {
            try? await clock.sleep(for: .milliseconds(100))
            pingCount.withLock { $0 += 1 }
          },
          isInBackground: { false }
        )
      async let status = deviceVolume.statusUpdates.first(where: { _ in true })
      await clock.advance(by: .milliseconds(100))
      _ = try await status
      pingCount.withLock { #expect($0 == 1) }
      await clock.advance(by: .seconds(1))
      await clock.advance(by: .milliseconds(100))
      pingCount.withLock { #expect($0 == 1) }
    }

    @Test("Stops Pinging When in the Background")
    @available(iOS 16, macOS 13, tvOS 16, watchOS 9, *)
    func stopsBackgroundPinging() async throws {
      let clock = TestClock()
      let isInBackground = OSAllocatedUnfairLock(initialState: false)
      let pingCount = OSAllocatedUnfairLock(initialState: 0)
      let deviceVolume = NoopDeviceOutputVolume()
        .pingForMuteStatus(
          interval: .seconds(1),
          threshold: .milliseconds(200),
          clock: clock,
          ping: {
            try? await clock.sleep(for: .milliseconds(100))
            pingCount.withLock { $0 += 1 }
          },
          isInBackground: { isInBackground.withLock { $0 } }
        )
      let token = deviceVolume.subscribe { _ in }
      await clock.advance(by: .milliseconds(100))
      pingCount.withLock { #expect($0 == 1) }
      isInBackground.withLock { $0 = true }
      await clock.advance(by: .seconds(1))
      await clock.advance(by: .milliseconds(100))
      pingCount.withLock { #expect($0 == 1) }
      token.cancel()
    }
  }

  @available(iOS 16, macOS 13, tvOS 16, watchOS 9, *)
  private actor SleepTime {
    var duration: Duration

    init(duration: Duration) {
      self.duration = duration
    }

    func setDuration(_ duration: Duration) {
      self.duration = duration
    }
  }

#endif
