#if canImport(SwiftUI)
  import SwiftUI

  extension EnvironmentValues {
    /// The current ``HapticsCompatability`` for the current hardware in the environment.
    @Entry public var hapticsCompatability = HapticsCompatability.currentForHardware
  }
#endif
