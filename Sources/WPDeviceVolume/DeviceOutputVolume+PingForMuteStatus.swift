#if !os(watchOS)
import AudioToolbox
import os
import WPFoundation

#if canImport(UIKit)
import UIKit
#endif

// MARK: - Extension

extension DeviceOutputVolume where Self: Sendable {
  /// Sets ``DeviceOutputVolumeStatus/isMuted`` on emissions of this volume's ``statusUpdates``
  /// based on a ping hack using AudioToolbox.
  ///
  /// ```swift
  /// // Returns a DeviceOutputVolume instance that uses AVAudioSession to check the global output
  /// // volume and the AudioToolbox technique to detect if the device is muted.
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

public final class _PingForMuteStatusDeviceVolume<
  Base: DeviceOutputVolume & Sendable,
  C: Clock
>: Sendable where C.Duration == Duration {
  private let interval: Duration
  private let threshold: Duration
  private let clock: C
  private let base: Base
  private let ping: @Sendable () async -> Void
  private let pingState = OSAllocatedUnfairLock(initialState: PingState())
  
  init(
    interval: Duration,
    threshold: Duration,
    clock: C,
    base: Base,
    ping: @Sendable @escaping () async -> Void
  ) {
    self.interval = interval
    self.threshold = threshold
    self.clock = clock
    self.base = base
    self.ping = ping
  }
}

// MARK: - PingState

extension _PingForMuteStatusDeviceVolume {
  struct PingState: Sendable {
    private var isMuted: Bool?
    private var id = 0
    private var callbacks = [Int: @Sendable (Bool) -> Void]()
    private var pingTask: Task<Void, Never>?
    
    mutating func register(
      _ callback: @Sendable @escaping (Bool) -> Void,
      beginPingTaskIfNeeded task: @Sendable @escaping () async -> Void
    ) -> Int {
      let shouldBeginPingTask = self.callbacks.isEmpty
      let id = self.id
      defer { self.id += 1 }
      self.callbacks[id] = callback
      if let isMuted {
        callback(isMuted)
      }
      if shouldBeginPingTask {
        self.pingTask = Task { await task() }
      }
      return id
    }
    
    mutating func emit(isMuted: Bool) {
      self.isMuted = isMuted
      self.callbacks.values.forEach { $0(isMuted) }
    }
    
    mutating func unregister(id: Int) {
      self.callbacks.removeValue(forKey: id)
      if self.callbacks.isEmpty {
        self.pingTask?.cancel()
        self.pingTask = nil
      }
    }
  }
}

// MARK: - DeviceOutputVolume Conformance

extension _PingForMuteStatusDeviceVolume: DeviceOutputVolume {
  public func subscribe(
    _ callback: @escaping @Sendable (Result<DeviceOutputVolumeStatus, any Error>) -> Void
  ) -> DeviceOutputVolumeSubscription {
    let state = RemoveDuplicatesState(callback)
    let callbackId = self.pingState.withLock {
      $0.register { isMuted in
        state.emit { $0.isMuted = isMuted }
      } beginPingTaskIfNeeded: {
        await self.pingForMuteStatus()
        for await _ in AsyncTimerSequence(interval: self.interval, clock: self.clock) {
          await self.pingForMuteStatus()
        }
      }
    }
    let subscription = self.base.subscribe { result in
      do {
        try state.emit { $0.outputVolume = try result.get().outputVolume }
      } catch {
        state.emit(error: error)
      }
    }
    return DeviceOutputVolumeSubscription { [weak self] in
      subscription.cancel()
      self?.pingState.withLock { $0.unregister(id: callbackId) }
    }
  }
  
  private func pingForMuteStatus() async {
    let time = await self.clock.measure { await self.ping() }
    let isMuted = time < self.threshold
    self.pingState.withLock { $0.emit(isMuted: isMuted) }
  }
}

// MARK: - AudioToolboxPinger

private final class AudioToolboxPinger: Sendable {
  private let soundId: SystemSoundID
  
  init() {
    let url = Bundle.module.assumingURL(forResource: "muted-sound", withExtension: "aiff")
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
