import Perception
import AVFoundation

// MARK: - DeviceOutputVolumeModel

/// An `Observable`/`Perceptible` model to observe a specified ``DeviceOutputVolumeStatus`` in a
/// UI context.
///
/// In SwiftUI, you can access the instance that observes the current device's system volume
/// through the `EnvironmentValues`.
/// ```swift
/// struct SoundEffectPickerView: View {
///   @Environment(\.systemDeviceOutputVolume) var outputVolume
///   @Binding var soundEffectName: String
///
///   var body: some View {
///     Form {
///       if self.outputVolume.status.isMuted {
///         Text("Your device is muted! Turn off silent mode so you can hear sound effects!")
///       } else if !self.outputVolume.status.hasVolume {
///         Text("Your volume is turned all the way down! Turn up your volume so you can hear sound effects!")
///       }
///       Picker("Sound Effect", selection: self.$soundEffectName) {
///         ForEach(["Air Horn", "Wilhelm", "Instant Transmission"], id: \.self) {
///           Text($0)
///         }
///       }
///     }
///   }
/// }
/// ```
///
/// There is also a ``default`` instance that can be used outside of SwiftUI. By default, the
/// instance in `EnvironmentValues` and the default instance are the same.
@MainActor
@Perceptible
public final class DeviceOutputVolumeModel {
  /// The current ``DeviceOutputVolumeStatus``.
  public private(set) var status = DeviceOutputVolumeStatus(
    outputVolume: 0,
    isMuted: false
  )
  
  /// An error if one occurred when observing the ``DeviceOutputVolume``.
  ///
  /// If this value is non-nil, then ``status`` will no longer be updated.
  public private(set) var error: (any Error)?
  
  @PerceptionIgnored private var task: TaskHolder?
  
  /// Initializes this model with an escaping closure to create the ``DeviceOutputVolume`` instance
  /// to observe.
  ///
  /// - Parameter volume: An escaping closure to create the ``DeviceOutputVolume`` instance to
  /// observe.
  public init(_ volume: @escaping () throws -> some DeviceOutputVolume) {
    self.task = TaskHolder(
      Task {
        do {
          for try await status in try volume().statusUpdates {
            self.status = status
          }
        } catch {
          self.error = error
        }
      }
    )
  }
}

// MARK: - Convenience Init

extension DeviceOutputVolumeModel {
  /// Initializes this model with an ``DeviceOutputVolume`` instance to observe.
  ///
  /// - Parameter volume: The ``DeviceOutputVolume`` instance to observe.
  public convenience init(_ volume: @autoclosure @escaping () throws -> some DeviceOutputVolume) {
    self.init { try volume() }
  }
}

// MARK: - Default Instance

extension DeviceOutputVolumeModel {
  /// Returns the default instance of this model.
  ///
  /// On macOS, this instance is backed by ``CoreAudioDeviceOutputVolume``.
  ///
  /// On watchOS, this instance is backed by the shared `AVAudioSession`. The watchOS instance
  /// does not detect whether or not the device is in silent mode because watchOS does not have an
  /// API to detect silent mode.
  ///
  /// On all other platforms, this is backed by the shared `AVAudioSession` and
  /// ``DeviceOutputVolume/pingForMuteStatus(interval:threshold:clock:)``. The latter extension
  /// method uses AudioToolbox to repeatedly play a muted sound at a specified interval to detect
  /// if the device is in silent mode. If the playback time of the muted sound is instantaneous,
  /// then the device is inferred to be in silent mode.
  public static let `default`: DeviceOutputVolumeModel = {
#if os(macOS)
    DeviceOutputVolumeModel { try CoreAudioDeviceOutputVolume() }
#elseif os(watchOS)
    DeviceOutputVolumeModel(AVAudioSession.sharedInstance())
#else
    DeviceOutputVolumeModel(AVAudioSession.sharedInstance().pingForMuteStatus())
#endif
  }()
}

// MARK: - TaskHoler

extension DeviceOutputVolumeModel {
  // NB: Swift 6 does not allow us to cancel the task in the deinit since we're marked with
  // @MainActor, so we can delegate the deinit to this wrapper class.
  private final class TaskHolder {
    private let task: Task<Void, Never>
    
    init(_ task: Task<Void, Never>) {
      self.task = task
    }
    
    deinit { self.task.cancel() }
  }
}
