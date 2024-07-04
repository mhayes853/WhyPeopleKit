import SwiftUI

#if canImport(CoreHaptics)
import CoreHaptics
#endif

// MARK: - HapticsCompatability

/// A data type that describes the availabiltiy of haptics for a device.
public struct HapticsCompatability: Hashable, Sendable {
  /// Whether or not the device supports haptic feedback.
  public let supportsFeedback: Bool
  
  /// Whether or not the device supports custom sound effects alongside haptic feedback.
  public let supportsCustomAudio: Bool
  
  public init(supportsFeedback: Bool, supportsCustomAudio: Bool) {
    self.supportsFeedback = supportsFeedback
    self.supportsCustomAudio = supportsCustomAudio
  }
}

// MARK: - Partial Support

extension HapticsCompatability {
  /// Whether or not the device has support for either feedback or audio.
  public var hasPartialSupport: Bool {
    self.supportsCustomAudio || self.supportsFeedback
  }
}

// MARK: - Current For Hardware

extension HapticsCompatability {
  /// The ``HapticsCompatability`` for the current hardware.
  public static var currentForHardware: Self {
#if canImport(CoreHaptics)
    let capabilities = CHHapticEngine.capabilitiesForHardware()
    return Self(
      supportsFeedback: capabilities.supportsHaptics,
      supportsCustomAudio: capabilities.supportsAudio
    )
#else
    Self(supportsFeedback: true, supportsCustomAudio: false)
#endif
  }
}

// MARK: - Environment Value

extension EnvironmentValues {
  /// The current ``HapticsCompatability`` for the current hardware in the environment.
  @Entry public var hapticsCompatability = HapticsCompatability.currentForHardware
}
