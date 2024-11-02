import Perception
import WPSwiftNavigation

// MARK: - DeviceOutputVolumeModel

/// An `Observable`/`Perceptible` model to observe a specified ``DeviceOutputVolumeStatus`` in a
/// UI context.
///
/// In SwiftUI, you can access the instance that observes the current device's system volume
/// through the `EnvironmentValues`.
/// ```swift
/// struct SoundEffectPickerView: View {
///   @Environment(\.systemDeviceOutputVolume) var volume
///   @Binding var soundEffectName: String
///
///   var body: some View {
///     Form {
///       if self.volume.isMuted {
///         Text("Your device is muted! Turn off silent mode so you can hear sound effects!")
///       } else if !self.volume.hasVolume {
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
@dynamicMemberLookup
public final class DeviceOutputVolumeModel {
  /// The current ``DeviceOutputVolumeStatus``.
  public private(set) var status = DeviceOutputVolumeStatus(outputVolume: 0)

  /// An error if one occurred when observing the ``DeviceOutputVolume``.
  ///
  /// If this value is non-nil, then ``status`` will no longer be updated.
  public private(set) var error: (any Error)?

  /// The transaction to use when the state changes.
  @PerceptionIgnored public var transaction: UITransaction

  @PerceptionIgnored private var subscription: DeviceOutputVolumeSubscription?

  /// Initializes this model with an escaping closure to create the ``DeviceOutputVolume`` instance
  /// to observe.
  ///
  /// - Parameters:
  ///    - transaction: The transaction to use when the state changes.
  ///    - volume: An escaping closure to create the ``DeviceOutputVolume`` instance to observe.
  public init(
    transaction: UITransaction = UITransaction(),
    _ volume: @escaping () throws -> some DeviceOutputVolume
  ) {
    do {
      self.transaction = transaction
      self.subscription = try volume()
        .subscribe { result in
          Task { @MainActor in
            switch result {
            case let .failure(error):
              withMultiplatformTransaction(self.transaction) { self.error = error }
            case let .success(status):
              withMultiplatformTransaction(self.transaction) { self.status = status }
            }
          }
        }
    } catch {
      withMultiplatformTransaction(self.transaction) { self.error = error }
    }
  }
}

// MARK: - Convenience Init

extension DeviceOutputVolumeModel {
  /// Initializes this model with an ``DeviceOutputVolume`` instance to observe.
  ///
  /// - Parameters:
  ///    - transaction: The transaction to use when the state changes.
  ///    - volume: An escaping closure to create the ``DeviceOutputVolume`` instance to observe.
  public convenience init(
    transaction: UITransaction = UITransaction(),
    _ volume: @autoclosure @escaping () throws -> some DeviceOutputVolume
  ) {
    self.init(transaction: transaction) { try volume() }
  }
}

// MARK: - Dynamic Member Lookup

extension DeviceOutputVolumeModel {
  public subscript<Value>(
    dynamicMember keyPath: KeyPath<DeviceOutputVolumeStatus, Value>
  ) -> Value {
    self.status[keyPath: keyPath]
  }
}

// MARK: - Default Instance

#if !os(Linux)
  extension DeviceOutputVolumeModel {
    /// Returns the an instance of this model that tracks the system default volume.
    ///
    /// On macOS, this instance is backed by ``CoreAudioDeviceOutputVolume``.
    ///
    /// On watchOS, this instance is backed by  ``AVAudioSessionDeviceOutputVolume``. The watchOS
    /// instance does not detect whether or not the device is in silent mode because watchOS does
    /// not have an API to detect silent mode.
    ///
    /// On all other platforms, this is backed by ``AVAudioSessionDeviceOutputVolume`` and
    /// ``DeviceOutputVolume/pingForMuteStatus(interval:threshold:clock:)``. The latter extension
    /// method uses AudioToolbox to repeatedly play a muted sound at a specified interval to detect
    /// if the device is in silent mode. If the playback time of the muted sound is instantaneous,
    /// then the device is inferred to be in silent mode.
    public static let systemDefault = DeviceOutputVolumeModel { try .systemDefault() }

    /// Returns the an instance of this model that tracks the system default volume.
    ///
    /// On macOS, this instance is backed by ``CoreAudioDeviceOutputVolume``.
    ///
    /// On watchOS, this instance is backed by  ``AVAudioSessionDeviceOutputVolume``. The watchOS
    /// instance does not detect whether or not the device is in silent mode because watchOS does
    /// not have an API to detect silent mode.
    ///
    /// On all other platforms, this is backed by ``AVAudioSessionDeviceOutputVolume`` and
    /// ``DeviceOutputVolume/pingForMuteStatus(interval:threshold:clock:)``. The latter extension
    /// method uses AudioToolbox to repeatedly play a muted sound at a specified interval to detect
    /// if the device is in silent mode. If the playback time of the muted sound is instantaneous,
    /// then the device is inferred to be in silent mode.
    ///
    /// - Parameters:
    ///   - transaction: A `UITransaction` that is used for state updates.
    public static func systemDefault(transaction: UITransaction) -> DeviceOutputVolumeModel {
      DeviceOutputVolumeModel(transaction: transaction) { try .systemDefault() }
    }
  }
#endif

// MARK: - SwiftUI

#if canImport(SwiftUI)
  import SwiftUI

  extension DeviceOutputVolumeModel {
    /// Initializes this model with an ``DeviceOutputVolume`` instance to observe.
    ///
    /// - Parameters:
    ///    - animation: The `Animation` to use when the state changes.
    ///    - volume: An escaping closure to create the ``DeviceOutputVolume`` instance to observe.
    public convenience init(
      animation: Animation?,
      _ volume: @escaping () throws -> some DeviceOutputVolume
    ) {
      self.init(transaction: UITransaction(animation: animation)) {
        try volume()
      }
    }

    /// Returns the an instance of this model that tracks the system default volume.
    ///
    /// On macOS, this instance is backed by ``CoreAudioDeviceOutputVolume``.
    ///
    /// On watchOS, this instance is backed by  ``AVAudioSessionDeviceOutputVolume``. The watchOS
    /// instance does not detect whether or not the device is in silent mode because watchOS does
    /// not have an API to detect silent mode.
    ///
    /// On all other platforms, this is backed by ``AVAudioSessionDeviceOutputVolume`` and
    /// ``DeviceOutputVolume/pingForMuteStatus(interval:threshold:clock:)``. The latter extension
    /// method uses AudioToolbox to repeatedly play a muted sound at a specified interval to detect
    /// if the device is in silent mode. If the playback time of the muted sound is instantaneous,
    /// then the device is inferred to be in silent mode.
    ///
    /// - Parameters:
    ///   - animation: The `Animation` to use when the state changes.
    public static func systemDefault(animation: Animation?) -> DeviceOutputVolumeModel {
      DeviceOutputVolumeModel(animation: animation) { try .systemDefault() }
    }
  }
#endif
