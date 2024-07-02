#if !os(watchOS)
import AudioToolbox
import AsyncAlgorithms

#if canImport(UIKit)
import UIKit
#endif

// MARK: - Extension

extension DeviceOutputVolume where Self: Sendable {
  /// Sets ``DeviceOutputVolumeStatus/isMuted`` on emissions of this volume's ``statusUpdates``
  /// based on a ping hack using AudioToolbox.
  ///
  /// ```swift
  /// // Returns a DeviceOutputVolume instance that uses AVAudioSession to check the global output volume
  /// // and the AudioToolbox technique to detect if the device is muted.
  /// let volume = try AVAudioSessionDeviceOutputVolume().pingForMuteStatus()
  /// ```
  ///
  /// iOS does not have a built-in API to detect the position of the ringer. The only way to
  /// detect the position of the ringer is to play a muted sound with AudioToolbox, and check if
  /// the playback length is under the specified threshold. If the playback length is under the
  /// specified threshold, then the device is muted.
  /// 
  /// This extension overrides the resulting ``DeviceOutputVolumeStatus/isMuted`` value of this
  /// ``DeviceOutputVolume`` instance.
  ///
  /// - Parameters:
  ///   - interval: The interval to ping at.
  ///   - threshold: The threshold that the playback length must be under in order to conside the
  ///   device to be muted.
  ///   - clock: A `Clock` to use to control the interval.
  /// - Returns: A new ``DeviceOutputVolume`` instance that uses the
  /// ``DeviceOutputVolumeStatus/outputVolume`` value of this instance, and overrides the
  /// ``DeviceOutputVolumeStatus/isMuted`` value of this instance when emitting status updates.
  public func pingForMuteStatus<C: Clock>(
    interval: Duration = .milliseconds(750),
    threshold: Duration = .milliseconds(100),
    clock: C = ContinuousClock()
  ) -> _PingForMuteStatusDeviceVolume<Self, C> where C.Duration == Duration {
    let pinger = AudioToolboxPinger()
    return self.pingForMuteStatus(
      interval: interval,
      threshold: threshold,
      clock: clock,
      ping: pinger.ping
    )
  }
  
  func pingForMuteStatus<C: Clock>(
    interval: Duration,
    threshold: Duration,
    clock: C,
    ping: @Sendable @escaping () async -> Void
  ) -> _PingForMuteStatusDeviceVolume<Self, C> where C.Duration == Duration {
    _PingForMuteStatusDeviceVolume(
      interval: interval,
      threshold: threshold,
      clock: clock,
      base: self,
      ping: ping
    )
  }
}

// MARK: - PingForMuteStatus Type

public struct _PingForMuteStatusDeviceVolume<
  Base: DeviceOutputVolume & Sendable,
  C: Clock
>: Sendable where C.Duration == Duration {
  let interval: Duration
  let threshold: Duration
  let clock: C
  let base: Base
  let ping: @Sendable () async -> Void
}

// MARK: - DeviceOutputVolume Conformance

extension _PingForMuteStatusDeviceVolume: DeviceOutputVolume {
  public typealias StatusUpdates = AsyncRemoveDuplicatesSequence<
    AsyncThrowingStream<DeviceOutputVolumeStatus, Error>
  >
  
  public var statusUpdates: StatusUpdates {
    AsyncThrowingStream<DeviceOutputVolumeStatus, Error> { continuation in
      let task = Task {
        do {
          // NB: Cancellation propogates to async let when the continuation is terminated.
          let state = StatusUpdatesState(continuation: continuation)
          async let timer: Void = self.runTimerSequence(state: state)
          try await self.runBaseSequence(state: state)
          await timer
        } catch {
          continuation.finish(throwing: error)
        }
      }
      continuation.onTermination = { @Sendable _ in task.cancel() }
    }
    .removeDuplicates()
  }
  
  private func runTimerSequence(state: StatusUpdatesState) async {
    await state.setMuted(await self.pingForMuteStatus())
    for await _ in AsyncTimerSequence(interval: self.interval, clock: self.clock) {
      await state.setMuted(await self.pingForMuteStatus())
    }
  }
  
  private func runBaseSequence(state: StatusUpdatesState) async throws {
    for try await newStatus in self.base.statusUpdates {
      await state.setOutputVolume(newStatus.outputVolume)
    }
  }
  
  private func pingForMuteStatus() async -> Bool {
    let time = await self.clock.measure { await self.ping() }
    return time < self.threshold
  }
  
  private final actor StatusUpdatesState {
    private var status = DeviceOutputVolumeStatus(outputVolume: 0, isMuted: false) {
      didSet { self.continuation.yield(self.status) }
    }
    private let continuation: AsyncThrowingStream<DeviceOutputVolumeStatus, Error>.Continuation
    
    init(continuation: AsyncThrowingStream<DeviceOutputVolumeStatus, Error>.Continuation) {
      self.continuation = continuation
    }
    
    func setOutputVolume(_ outputVolume: Double) {
      self.status = DeviceOutputVolumeStatus(outputVolume: outputVolume, isMuted: self.status.isMuted)
    }
    
    func setMuted(_ isMuted: Bool) {
      self.status = DeviceOutputVolumeStatus(outputVolume: self.status.outputVolume, isMuted: isMuted)
    }
  }
}

// MARK: - AudioToolboxPinger

private final class AudioToolboxPinger: Sendable {
  private let soundId: SystemSoundID
  
  init() {
    guard let url = Bundle.module.url(forResource: "muted-sound", withExtension: "aiff") else {
      fatalError("Unable to find muted-sound in bundle.")
    }
    var _soundId: SystemSoundID = 0
    AudioServicesCreateSystemSoundID(url as CFURL, &_soundId)
    var respectSilentMode: UInt32 = 1
    AudioServicesSetProperty(
      kAudioServicesPropertyIsUISound,
      UInt32(MemoryLayout.size(ofValue: _soundId)),
      &_soundId,
      UInt32(MemoryLayout.size(ofValue: respectSilentMode)),
      &respectSilentMode
    )
    
    self.soundId = _soundId
  }
  
  deinit {
    AudioServicesRemoveSystemSoundCompletion(self.soundId)
    AudioServicesDisposeSystemSoundID(self.soundId)
  }
  
  func ping() async {
#if canImport(UIKit)
    guard await UIApplication.shared.applicationState == .active else { return }
#endif
    await withUnsafeContinuation { continuation in
      AudioServicesPlaySystemSoundWithCompletion(
        self.soundId,
        continuation.resume
      )
    }
  }
}

#endif
