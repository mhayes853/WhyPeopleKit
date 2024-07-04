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

### `CHHapticPatternConvertible`

This protocol is used as the associated type requirement of the `CHHapticEngine` conformance to `HapticsPlayable`, and it has a single method in which the conforming type must return a `CHHapticPattern`.
