#  WPDeviceVolume

A cross-platform library for accessing information about the volume and mute status of a device in a simple manner.

## Overview

Often times in applications, we want to customize our UI based on whether or not the device is muted. This is annoying to do on Apple platforms due to a lack of APIs, or having to go through a bunch of low-level methods. This library provides a high-level API to access this information, and it can be done easily from within a SwiftUI view using the `systemDeviceOutputVolume` environment property.

```swift
struct SoundEffectPickerView: View {
  @Environment(\.systemDeviceOutputVolume) var volume
  @Binding var soundEffectName: String
  
  var body: some View {
    Form {
      if self.volume.isMuted {
        Text("Your device is muted! Turn off silent mode so you can hear sound effects!")
      } else if !self.volume.hasVolume {
        Text("Your volume is turned all the way down! Turn up your volume so you can hear sound effects!")
      }
      Picker("Sound Effect", selection: self.$soundEffectName) {
        ForEach(["Air Horn", "Wilhelm", "Instant Transmission"], id: \.self) {
          Text($0)
        }
      }
    }
  }
}
```

The frameworks used by `systemDeviceOutputVolume` under the hood differ by platform:
- On macOS, CoreAudio is used.
- On watchOS, `AVAudioSession` is used.
  - watchOS does not provide a way to detect whether or not the device is silent mode. Therefore, the `isMuted` property is not available on watchOS. Instead, you can use the `hasVolume` property to determine if the device's volume output is zero.
- On iOS, visionOS, and tvOS, a combination of `AVAudioSession` and AudioToolbox is used.
  - This combination relies on `AVAudioSession` to provide the `outputVolume` property, and a well known hack using AudioToolbox to provide `isMuted`. The hack involves repeatedly playing a muted sound at a specified interval, and detecting if the playback time was nearly instant. If so, the device is in silent mode.

This environment property is an instance of `DeviceOutputVolumeModel`. `DeviceOutputVolumeModel` conforms to the `Observable` and `Perceptible` (see [swift-perception](https://github.com/pointfreeco/swift-perception)) protocols. You can also create instances of this model using a conformance of the `DeviceOutputVolume` protocol, or you can use the `default` singleton instance.

### Non-SwiftUI Usage

If you're not using SwiftUI, you can also use an `AsyncSequence` to observe volume updates through the `DeviceOutputVolume` protocol.

```swift
func observeOutputVolume(_ volume: some DeviceOutputVolume) async throws {
  for try await status in volume.statusUpdates {
    print("Is muted: \(status.isMuted). Volume: \(status.outputVolume).")
  }
}
```
