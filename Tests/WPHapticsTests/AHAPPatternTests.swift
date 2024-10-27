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
}

extension AHAPPattern {
  fileprivate static let test = Self(
    pattern: [
      .event(
        .hapticTransient(
          HapticTransientEvent(time: 0, parameters: [.hapticIntensity: 0.5, .hapticSharpness: 0.5])
        )
      ),
      .event(
        .hapticContinuous(
          HapticContinuousEvent(
            time: 0,
            duration: 2,
            parameters: [.hapticIntensity: 0.5, .hapticSharpness: 0.5]
          )
        )
      ),
      .event(
        .audioCustom(
          AudioCustomEvent(time: 0.5, waveformPath: "coins", parameters: [.audioVolume: 0.3])
        )
      ),
      .parameterCurve(
        ParameterCurve(
          id: .hapticIntensityControl,
          time: 0,
          controlPoints: [
            ParameterCurve.ControlPoint(time: 0, value: 0),
            ParameterCurve.ControlPoint(time: 0.1, value: 1),
            ParameterCurve.ControlPoint(time: 2, value: 0.5)
          ]
        )
      ),
      .parameterCurve(
        ParameterCurve(
          id: .hapticSharpnessControl,
          time: 2,
          controlPoints: [
            ParameterCurve.ControlPoint(time: 0, value: 0),
            ParameterCurve.ControlPoint(time: 0.1, value: 1),
            ParameterCurve.ControlPoint(time: 2, value: 0.5)
          ]
        )
      ),
      .dynamicParameter(DynamicParameter(id: .audioVolumeControl, time: 0.5, value: 0.8))
    ]
  )
}
