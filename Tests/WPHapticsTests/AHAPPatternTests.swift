import CustomDump
import Foundation
import InlineSnapshotTesting
import Testing
import WPHaptics
import WPSnapshotTesting

@Suite("AHAPPattern tests")
struct AHAPPatternTests {
  @Test("To and From AHAP Data")
  func toAndFromAHAPData() throws {
    let pattern = AHAPPattern.test
    let data = pattern.data()
    let decodedPattern = try AHAPPattern(from: data)
    expectNoDifference(pattern, decodedPattern)
  }

  @Test("From Raw AHAP Data")
  func fromAHAPData() throws {
    let data = """
          {
            "Version": 1,
            "Pattern": [
              {
                "Event": {
                  "EventType": "HapticTransient",
                  "Time": 0,
                  "EventParameters": [
                    {
                      "ParameterID": "HapticIntensity",
                      "ParameterValue": 0.5
                    },
                    {
                      "ParameterID": "HapticSharpness",
                      "ParameterValue": 0.5
                    }
                  ]
                }
              },
              {
                "Event": {
                  "EventType": "HapticContinuous",
                  "Time": 0,
                  "EventDuration": 2,
                  "EventParameters": [
                    {
                      "ParameterID": "HapticIntensity",
                      "ParameterValue": 0.5
                    },
                    {
                      "ParameterID": "HapticSharpness",
                      "ParameterValue": 0.5
                    }
                  ]
                }
              },
              {
                "Event": {
                  "EventType": "AudioCustom",
                  "EventWaveformPath": "coins",
                  "Time": 0.5,
                  "EventParameters": [
                    {
                      "ParameterID": "AudioVolume",
                      "ParameterValue": 0.3
                    }
                  ]
                }
              },
              {
                "ParameterCurve": {
                  "ParameterID": "HapticIntensityControl",
                  "Time": 0,
                  "ParameterCurveControlPoints": [
                    {
                      "ParameterValue": 0,
                      "Time": 0
                    },
                    {
                      "ParameterValue": 1,
                      "Time": 0.1
                    },
                    {
                      "ParameterValue": 0.5,
                      "Time": 2
                    }
                  ]
                }
              },
              {
                "ParameterCurve": {
                  "ParameterID": "HapticSharpnessControl",
                  "Time": 2,
                  "ParameterCurveControlPoints": [
                    {
                      "ParameterValue": 0,
                      "Time": 0
                    },
                    {
                      "ParameterValue": 1,
                      "Time": 0.1
                    },
                    {
                      "ParameterValue": 0.5,
                      "Time": 2
                    }
                  ]
                }
              },
              {
                "Parameter": {
                  "ParameterID": "AudioVolumeControl",
                  "Time": 0.5,
                  "ParameterValue": 0.8
                }
              }
            ]
          }
      """
      .data(using: .utf8)!

    let pattern = try AHAPPattern(from: data)
    expectNoDifference(pattern, .test)
  }

  @Test("Data Snapshot")
  func snapshot() throws {
    assertSnapshot(of: AHAPPattern.test, as: .ahap)
  }

  @Test("Throws When Invalid Data Decoded")
  func invalidData() throws {
    #expect(throws: Error.self) {
      try AHAPPattern(from: Data("BAD".utf8))
    }
  }

  @Test("To and From Contents of URL")
  @available(iOS 16, macOS 13, tvOS 16, watchOS 9, *)
  func contentsOfURL() throws {
    let pattern = AHAPPattern.test
    let url = URL.documentsDirectory.appending(path: "test.ahap")
    try pattern.write(to: url)
    let newPattern = try AHAPPattern(contentsOf: url)
    #expect(pattern == newPattern)
    try FileManager.default.removeItem(at: url)
  }

  @Test("Encode then Decode Custom Audio Event")
  func encodeThenDecodeCustomAudio() throws {
    let event = AHAPPattern.AudioCustomEvent(
      time: 0,
      waveformPath: "test.caf",
      waveformLoopEnabled: false,
      waveformUseVolumeEnvelope: false,
      duration: 2.2,
      parameters: AHAPPattern.AudioParameters()
    )
    let data = try JSONEncoder().encode(event)
    let decodedEvent = try JSONDecoder().decode(AHAPPattern.AudioCustomEvent.self, from: data)
    expectNoDifference(event, decodedEvent)
  }
}

extension AHAPPattern {
  fileprivate static let test = Self(
    .event(.hapticTransient(time: 0, parameters: [.hapticIntensity: 0.5, .hapticSharpness: 0.5])),
    .event(
      .hapticContinuous(
        time: 0,
        duration: 2,
        parameters: [.hapticIntensity: 0.5, .hapticSharpness: 0.5]
      )
    ),
    .event(.audioCustom(time: 0.5, waveformPath: "coins", parameters: [.audioVolume: 0.3])),
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
