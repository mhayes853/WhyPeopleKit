#if canImport(SwiftUI)
  import SwiftUI

  extension EnvironmentValues {
    /// The ``DeviceOutputVolumeModel`` that represents the system output volume of the current
    /// device in this environment.
    public var systemDeviceOutputVolume: DeviceOutputVolumeModel {
      get { self[DeviceOutputVolumeModelKey.self] }
      set { self[DeviceOutputVolumeModelKey.self] = newValue }
    }

    @MainActor
    private struct DeviceOutputVolumeModelKey: @preconcurrency EnvironmentKey {
      static let defaultValue = DeviceOutputVolumeModel.systemDefault
    }
  }
#endif
