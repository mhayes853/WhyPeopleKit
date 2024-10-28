#  WPHaptics

A thin wrapper layer that makes haptics easier to work with cross-platform.

## Overview

### `HapticsCompatability`

This struct describes what features of haptics that the current hardware supports. You can get the instance that applies to your hardware by using `HapticsCompatability.currentForHardware`. You can also create your own instances of this struct, which is mainly useful for overriding the `hapticsCompatability` SwiftUI environment value in previews.

```swift
#Preview {
  HapticsAndAudioSettingsView(isFeedbackEnabled: $isFeedbackEnabled, isAudioEnabled: $isAudioEnabled)
    .environment(
      \.hapticsCompatability,
      HapticsCompatability(supportsFeedback: true, supportsAudio: false)
    )
}
```

### `HapticsPlayable`

This protocol abstracts playing haptics across different platforms. It has a single associated type that represents a haptic event, and has a single method requirement to play an instance of the haptic event. This package features a WatchKit, CoreHaptics, and a Mock implementation. The mock implementation is useful for inspecting recorded haptic events dureing testing.

### `AHAPPattern`

A type that allows type-safe creation of AHAP patterns on both apple platforms, and platforms that cannot import CoreHaptics such as linux servers.

It conforms to both the Hashable and Codable protocols which allow AHAP patterns to be compared for equality, and to be encoded and decoded from JSON respectively.

```swift
extension AHAPPattern {
  static let examplePattern = Self(
    .event(.hapticTransient(time: 0, parameters: [.hapticIntensity: 0.5, .hapticSharpness: 0.5])),
    .event(
      .hapticContinuous(
        time: 0,
        duration: 2,
        parameters: [.hapticIntensity: 0.5, .hapticSharpness: 0.5]
      )
    ),
    .event(.audioCustom(time: 0.5, waveformPath: "coins.caf", parameters: [.audioVolume: 0.3])),
    .parameterCurve(
      id: .hapticIntensityControl,
      time: 0,
      controlPoints: [
        .point(time: 0, value: 0),
        .point(time: 0.1, value: 1),
        .point(time: 2, value: 0.5)
      ]
    ),
    .parameterCurve(
      id: .hapticSharpnessControl,
      time: 2,
      controlPoints: [
        .point(time: 0, value: 0),
        .point(time: 0.1, value: 1),
        .point(time: 2, value: 0.5)
      ]
    ),
    .dynamicParameter(id: .audioVolumeControl, time: 0.5, value: 0.8)
  )
}
```
