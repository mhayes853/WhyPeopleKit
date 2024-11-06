#if os(iOS)
  import AudioToolbox
  import WPFoundation
  import UIKit
  import _WPDeviceVolumeMuteSound

  // MARK: - Extension

  @available(iOS 16, *)
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
    ) -> _PingForMuteStatusDeviceVolume<Self, ClockPingTimer<C>> where C.Duration == Duration {
      self.pingForMuteStatus(
        interval: TimeInterval(duration: interval),
        threshold: TimeInterval(duration: threshold),
        timer: ClockPingTimer(clock: clock)
      )
    }

    @_spi(Workaround) public func pingForMuteStatus<C: Clock>(
      interval: Duration,
      threshold: Duration,
      clock: C,
      ping: @Sendable @escaping () async -> Void,
      isInBackground: @Sendable @escaping () async -> Bool
    ) -> _PingForMuteStatusDeviceVolume<Self, ClockPingTimer<C>> where C.Duration == Duration {
      self.pingForMuteStatus(
        interval: TimeInterval(duration: interval),
        threshold: TimeInterval(duration: threshold),
        timer: ClockPingTimer(clock: clock),
        ping: ping,
        isInBackground: isInBackground
      )
    }
  }

  extension DeviceOutputVolume where Self: Sendable {
    /// Sets ``DeviceOutputVolumeStatus/isMuted`` on emissions of this volume's ``statusUpdates``
    /// based on a ping hack using AudioToolbox.
    ///
    /// ```swift
    /// // Returns a DeviceOutputVolume instance that uses AVAudioSession to check the global output
    /// // volume and the AudioToolbox technique to detect if the device is muted.
    /// let volume = try AVAudioSessionDeviceOutputVolume().pingForMuteStatus(queue: .global())
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
    ///   - queue: The queue to run the ping timer on.
    /// - Returns: A new ``DeviceOutputVolume`` instance that uses the
    /// ``DeviceOutputVolumeStatus/outputVolume`` value of this instance, and overrides the
    /// ``DeviceOutputVolumeStatus/isMuted`` value of this instance when emitting status updates.
    public func pingForMuteStatus(
      interval: TimeInterval = 0.75,
      threshold: TimeInterval = 0.1,
      queue: DispatchQueue
    ) -> _PingForMuteStatusDeviceVolume<Self, DispatchPingTimer> {
      self.pingForMuteStatus(
        interval: interval,
        threshold: threshold,
        timer: DispatchPingTimer(queue: queue)
      )
    }

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
    ///   - timer: A ``PingTimer`` to use to control the timing of pings.
    /// - Returns: A new ``DeviceOutputVolume`` instance that uses the
    /// ``DeviceOutputVolumeStatus/outputVolume`` value of this instance, and overrides the
    /// ``DeviceOutputVolumeStatus/isMuted`` value of this instance when emitting status updates.
    public func pingForMuteStatus<T: PingTimer>(
      interval: TimeInterval = 0.75,
      threshold: TimeInterval = 0.1,
      timer: T = DispatchPingTimer(queue: .global())
    ) -> _PingForMuteStatusDeviceVolume<Self, T> {
      let pinger = AudioToolboxPinger()
      return self.pingForMuteStatus(
        interval: interval,
        threshold: threshold,
        timer: timer,
        ping: pinger.ping,
        isInBackground: { await UIApplication.shared.applicationState != .active }
      )
    }

    private func pingForMuteStatus<T: PingTimer>(
      interval: TimeInterval,
      threshold: TimeInterval,
      timer: T,
      ping: @Sendable @escaping () async -> Void,
      isInBackground: @Sendable @escaping () async -> Bool
    ) -> _PingForMuteStatusDeviceVolume<Self, T> {
      _PingForMuteStatusDeviceVolume(
        interval: interval,
        threshold: threshold,
        timer: timer,
        base: self,
        ping: ping,
        isInBackground: isInBackground
      )
    }
  }

  // MARK: - PingTimer

  /// A timer to control the pinging in ``DeviceOutputVolume/pingForMuteStatus(interval:threshold:timer:)``.
  public protocol PingTimer: Sendable {
    associatedtype Ticks: AsyncSequence where Ticks.Element == Void

    /// An asynchronous sequence of timer ticks on the specified `interval`.
    ///
    /// - Parameter interval: The interval of the timer.
    /// - Returns: An asynchronous sequence of timer ticks.
    func ticks(on interval: TimeInterval) -> Ticks

    /// Measures the performance of the specified work in seconds.
    ///
    /// - Parameter work: A unit of work.
    /// - Returns: The duration of how long the work took to complete.
    func time(work: @Sendable () async -> Void) async -> TimeInterval
  }

  // MARK: - DispatchPingTimer

  /// A ``PingTimer`` using a dispatch queue as a timer source.
  public struct DispatchPingTimer {
    /// The queue used by this timer.
    public let queue: DispatchQueue

    /// Creates a dispatch ping timer.
    ///
    /// - Parameter queue: A queue to run timer operations on.
    public init(queue: DispatchQueue) {
      self.queue = queue
    }
  }

  extension DispatchPingTimer: PingTimer {
    public func ticks(on interval: TimeInterval) -> AsyncStream<Void> {
      AsyncStream { continuation in
        let timer = DispatchSource.makeTimerSource(queue: self.queue)
        timer.setEventHandler { continuation.yield() }
        timer.schedule(deadline: .now() + interval, repeating: interval)
        timer.resume()
        let lockedTimer = Lock(timer)
        continuation.onTermination = { _ in lockedTimer.withLock { $0.cancel() } }
      }
    }

    public func time(work: @Sendable () async -> Void) async -> TimeInterval {
      let start = CFAbsoluteTimeGetCurrent()
      await work()
      return CFAbsoluteTimeGetCurrent() - start
    }
  }

  // MARK: - ClockPingTimer

  /// A ``PingTimer`` that uses a `Clock`.
  @available(iOS 16, *)
  public struct ClockPingTimer<C: Clock> where C.Duration == Duration {
    /// The `Clock` used by this timer.
    public let clock: C

    /// Creates a ping timer with the specified clock.
    ///
    /// - Parameter clock: A `Clock`.
    public init(clock: C) {
      self.clock = clock
    }
  }

  @available(iOS 16, *)
  extension ClockPingTimer: PingTimer {
    public func ticks(on interval: TimeInterval) -> _AsyncTimerSequence<C> {
      _AsyncTimerSequence(interval: .seconds(interval), clock: self.clock)
    }

    public func time(work: @Sendable () async -> Void) async -> TimeInterval {
      TimeInterval(duration: await self.clock.measure(work))
    }
  }

  // MARK: - PingForMuteStatus Type

  public final class _PingForMuteStatusDeviceVolume<
    Base: DeviceOutputVolume & Sendable,
    Timer: PingTimer
  >: Sendable {
    private let interval: TimeInterval
    private let threshold: TimeInterval
    private let timer: Timer
    private let base: Base
    private let ping: @Sendable () async -> Void
    private let pingState = Lock(PingState())
    private let isInBackground: @Sendable () async -> Bool

    init(
      interval: TimeInterval,
      threshold: TimeInterval,
      timer: Timer,
      base: Base,
      ping: @Sendable @escaping () async -> Void,
      isInBackground: @Sendable @escaping () async -> Bool
    ) {
      self.interval = interval
      self.threshold = threshold
      self.timer = timer
      self.base = base
      self.ping = ping
      self.isInBackground = isInBackground
    }
  }

  // MARK: - PingState

  extension _PingForMuteStatusDeviceVolume {
    struct PingState: Sendable {
      private var isMuted: Bool?
      private var id = 0
      private var callbacks = [Int: @Sendable (Bool) -> Void]()
      private var pingTask: Task<Void, Error>?

      mutating func register(
        _ callback: @Sendable @escaping (Bool) -> Void,
        beginPingTaskIfNeeded task: @Sendable @escaping () async throws -> Void
      ) -> Int {
        let shouldBeginPingTask = self.callbacks.isEmpty
        let id = self.id
        defer { self.id += 1 }
        self.callbacks[id] = callback
        if let isMuted {
          callback(isMuted)
        }
        if shouldBeginPingTask {
          self.pingTask = Task { try await task() }
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
          for try await _ in self.timer.ticks(on: self.interval) {
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
      guard !(await self.isInBackground()) else { return }
      let time = await self.timer.time { await self.ping() }
      let isMuted = time < self.threshold
      self.pingState.withLock { $0.emit(isMuted: isMuted) }
    }
  }

  // MARK: - AudioToolboxPinger

  private final class AudioToolboxPinger: Sendable {
    private let soundId: SystemSoundID

    init() {
      var _soundId: SystemSoundID = 0
      AudioServicesCreateSystemSoundID(mutedSoundURL as CFURL, &_soundId)
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
      await withUnsafeContinuation { continuation in
        AudioServicesPlaySystemSoundWithCompletion(
          self.soundId,
          continuation.resume
        )
      }
    }
  }
#endif
