import Foundation

// MARK: - AHAPPattern

public struct AHAPPattern: Hashable, Sendable {
  public var version: Int
  public var pattern: [Element]

  public init(version: Int = 1, pattern: [AHAPPattern.Element]) {
    self.version = version
    self.pattern = pattern
  }
}

extension AHAPPattern: Codable {
  private enum CodingKeys: String, CodingKey {
    case version = "Version"
    case pattern = "Pattern"
  }
}

// MARK: - Data Functions

extension AHAPPattern {
  public enum DataOutputFormat {
    case prettyJson
    case json

    fileprivate var encoder: JSONEncoder {
      let encoder = JSONEncoder()
      if self == .prettyJson {
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
      }
      return encoder
    }
  }

  public func data(format: DataOutputFormat = .json) -> Data {
    try! format.encoder.encode(self)
  }

  public init(from data: Data) throws {
    self = try JSONDecoder().decode(Self.self, from: data)
  }
}

// MARK: - Element

extension AHAPPattern {
  public enum Element: Hashable, Sendable {
    case event(Event)
    case parameterCurve(ParameterCurve)
    case dynamicParameter(DynamicParameter)
  }
}

extension AHAPPattern.Element: Encodable {
  public func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    switch self {
    case let .dynamicParameter(p): try container.encode(p, forKey: .dynamicParameter)
    case let .event(e): try container.encode(e, forKey: .event)
    case let .parameterCurve(p): try container.encode(p, forKey: .parameterCurve)
    }
  }
}

extension AHAPPattern.Element: Decodable {
  public init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    if container.contains(.event) {
      self = try .event(container.decode(AHAPPattern.Event.self, forKey: .event))
    } else if container.contains(.dynamicParameter) {
      self = try .dynamicParameter(
        container.decode(AHAPPattern.DynamicParameter.self, forKey: .dynamicParameter)
      )
    } else if container.contains(.parameterCurve) {
      self = try .parameterCurve(
        container.decode(AHAPPattern.ParameterCurve.self, forKey: .parameterCurve)
      )
    } else {
      throw DecodingError.keyNotFound(
        CodingKeys.event,
        DecodingError.Context(
          codingPath: CodingKeys.allCases,
          debugDescription:
            "Ensure pattern elements contain one of the following keys: \"Event\", \"Parameter\", \"ParameterCurve\"."
        )
      )
    }
  }
}

extension AHAPPattern.Element {
  private enum CodingKeys: String, CodingKey, CaseIterable {
    case event = "Event"
    case parameterCurve = "ParameterCurve"
    case dynamicParameter = "Parameter"
  }
}

// MARK: - Event

extension AHAPPattern {
  public enum Event: Hashable, Sendable {
    case hapticTransient(HapticTransientEvent)
    case hapticContinuous(HapticContinuousEvent)
    case audioCustom(AudioCustomEvent)
    case audioContinuous(AudioContinuousEvent)
  }
}

extension AHAPPattern.Event: Encodable {
  public func encode(to encoder: any Encoder) throws {
    switch self {
    case let .audioContinuous(e): try e.encode(to: encoder)
    case let .audioCustom(e): try e.encode(to: encoder)
    case let .hapticContinuous(e): try e.encode(to: encoder)
    case let .hapticTransient(e): try e.encode(to: encoder)
    }
  }
}

extension AHAPPattern.Event: Decodable {
  public init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKey.self)
    switch try container.decode(AHAPPattern.EventType.self, forKey: .eventType) {
    case .audioContinuous:
      self = try .audioContinuous(AHAPPattern.AudioContinuousEvent(from: decoder))
    case .audioCustom:
      self = try .audioCustom(AHAPPattern.AudioCustomEvent(from: decoder))
    case .hapticContinuous:
      self = try .hapticContinuous(AHAPPattern.HapticContinuousEvent(from: decoder))
    case .hapticTransient:
      self = try .hapticTransient(AHAPPattern.HapticTransientEvent(from: decoder))
    }
  }

  private struct CodingKey: Swift.CodingKey {
    static let eventType = Self(stringValue: "EventType")

    var stringValue: String
    var intValue: Int?

    init(stringValue: String) {
      self.stringValue = stringValue
    }

    init?(intValue: Int) {
      return nil
    }
  }
}

// MARK: - Event Type

extension AHAPPattern {
  public enum EventType: String, Hashable, Sendable, Codable {
    case hapticTransient = "HapticTransient"
    case hapticContinuous = "HapticContinuous"
    case audioContinuous = "AudioContinuous"
    case audioCustom = "AudioCustom"
  }
}

// MARK: - Transient Event

extension AHAPPattern {
  public struct HapticTransientEvent: Hashable, Sendable {
    public private(set) var eventType = EventType.hapticTransient
    public var time: Double
    public var parameters: HapticParameters

    public init(time: Double, parameters: HapticParameters) {
      self.time = time
      self.parameters = parameters
    }
  }
}

extension AHAPPattern.HapticTransientEvent: Codable {
  private enum CodingKeys: String, CodingKey {
    case eventType = "EventType"
    case time = "Time"
    case parameters = "EventParameters"
  }
}

// MARK: - Continuous Event

extension AHAPPattern {
  public struct HapticContinuousEvent: Hashable, Sendable {
    public private(set) var eventType = EventType.hapticContinuous
    public var time: Double
    public var duration: Double
    public var parameters: HapticParameters

    public init(time: Double, duration: Double, parameters: HapticParameters) {
      self.time = time
      self.duration = duration
      self.parameters = parameters
    }
  }
}

extension AHAPPattern.HapticContinuousEvent: Codable {
  private enum CodingKeys: String, CodingKey {
    case eventType = "EventType"
    case time = "Time"
    case duration = "EventDuration"
    case parameters = "EventParameters"
  }
}

// MARK: - Haptic Parameters

extension AHAPPattern {
  public struct HapticParameters: _AHAPEventParameters {
    public var entries = [HapticParameterID: Double]()
    public init() {}
  }
}

// MARK: - Haptic Parameter ID

extension AHAPPattern {
  public enum HapticParameterID: String, Hashable, Sendable, Codable {
    case hapticIntensity = "HapticIntensity"
    case hapticSharpness = "HapticSharpness"
    case attackTime = "AttackTime"
    case decayTime = "DecayTime"
    case releaseTime = "ReleaseTime"
    case sustained = "Sustained"
  }
}

// MARK: - Audio Custom Event

extension AHAPPattern {
  public struct AudioCustomEvent: Hashable, Sendable {
    public private(set) var eventType = EventType.audioCustom
    public var time: Double
    public var waveformLoopEnabled = false
    public var waveformPath: String
    public var waveformUseVolumeEnvelope = false
    public var parameters = AudioParameters()

    public init(
      time: Double,
      waveformLoopEnabled: Bool = false,
      waveformPath: String,
      waveformUseVolumeEnvelope: Bool = false,
      parameters: AudioParameters = AudioParameters()
    ) {
      self.time = time
      self.waveformLoopEnabled = waveformLoopEnabled
      self.waveformPath = waveformPath
      self.waveformUseVolumeEnvelope = waveformUseVolumeEnvelope
      self.parameters = parameters
    }
  }
}

extension AHAPPattern.AudioCustomEvent: Encodable {
  private enum CodingKeys: String, CodingKey {
    case eventType = "EventType"
    case time = "Time"
    case waveformLoopEnabled = "EventWaveformLoopEnabled"
    case waveformPath = "EventWaveformPath"
    case waveformUseVolumeEnvelope = "EventWaveformUseVolumeEnvelope"
    case parameters = "EventParameters"
  }
}

extension AHAPPattern.AudioCustomEvent: Decodable {
  public init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.time = try container.decode(Double.self, forKey: .time)
    self.waveformPath = try container.decode(String.self, forKey: .waveformPath)
    self.parameters = try container.decode(AHAPPattern.AudioParameters.self, forKey: .parameters)
    self.waveformLoopEnabled =
      try container.decodeIfPresent(Bool.self, forKey: .waveformLoopEnabled) ?? false
    self.waveformUseVolumeEnvelope =
      try container.decodeIfPresent(Bool.self, forKey: .waveformUseVolumeEnvelope) ?? false
  }
}

// MARK: - Audio Continuous Event

extension AHAPPattern {
  public struct AudioContinuousEvent: Hashable, Sendable {
    public private(set) var eventType = EventType.audioContinuous
    public var time: Double
    public var duration: Double
    public var waveformLoopEnabled = false
    public var waveformPath: String
    public var waveformUseVolumeEnvelope = false
    public var parameters = AudioParameters()

    public init(
      time: Double,
      duration: Double,
      waveformLoopEnabled: Bool = false,
      waveformPath: String,
      waveformUseVolumeEnvelope: Bool = false,
      parameters: AudioParameters = AudioParameters()
    ) {
      self.time = time
      self.duration = duration
      self.waveformLoopEnabled = waveformLoopEnabled
      self.waveformPath = waveformPath
      self.waveformUseVolumeEnvelope = waveformUseVolumeEnvelope
      self.parameters = parameters
    }
  }
}

extension AHAPPattern.AudioContinuousEvent: Encodable {
  private enum CodingKeys: String, CodingKey {
    case eventType = "EventType"
    case time = "Time"
    case duration = "EventDuration"
    case waveformLoopEnabled = "EventWaveformLoopEnabled"
    case waveformPath = "EventWaveformPath"
    case waveformUseVolumeEnvelope = "EventWaveformUseVolumeEnvelope"
    case parameters = "EventParameters"
  }
}

extension AHAPPattern.AudioContinuousEvent: Decodable {
  public init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.time = try container.decode(Double.self, forKey: .time)
    self.duration = try container.decode(Double.self, forKey: .duration)
    self.waveformPath = try container.decode(String.self, forKey: .waveformPath)
    self.parameters = try container.decode(AHAPPattern.AudioParameters.self, forKey: .parameters)
    self.waveformLoopEnabled =
      try container.decodeIfPresent(Bool.self, forKey: .waveformLoopEnabled) ?? false
    self.waveformUseVolumeEnvelope =
      try container.decodeIfPresent(Bool.self, forKey: .waveformUseVolumeEnvelope) ?? false
  }
}

// MARK: - Audio Parameters

extension AHAPPattern {
  public struct AudioParameters: _AHAPEventParameters {
    public var entries = [AudioParameterID: Double]()
    public init() {}
  }
}

// MARK: - Audio Parameter ID

extension AHAPPattern {
  public enum AudioParameterID: String, Hashable, Sendable, Codable {
    case audioVolume = "AudioVolume"
    case audioPitch = "AudioPitch"
    case audioPan = "AudioPan"
    case audioBrightness = "AudioBrightness"
  }
}

// MARK: - Event Parameters

public protocol _AHAPEventParameters<ID>: Codable, Hashable, Sendable,
  ExpressibleByDictionaryLiteral
{
  associatedtype ID: Hashable, RawRepresentable where ID.RawValue == String

  var entries: [ID: Double] { get set }
  init()
}

extension _AHAPEventParameters {
  public func encode(to encoder: any Encoder) throws {
    let parameters = self.entries
      .map { (key, value) in SerializedParameter(id: key.rawValue, value: value) }
      .sorted { $0.id < $1.id }
    try parameters.encode(to: encoder)
  }

  public init(from decoder: any Decoder) throws {
    let parameters = try [SerializedParameter](from: decoder)
    self.init()
    for parameter in parameters {
      guard let id = ID(rawValue: parameter.id) else { continue }
      self.entries[id] = parameter.value
    }
  }
}

extension _AHAPEventParameters {
  public init(_ entries: [ID: Double]) {
    self.init()
    self.entries = entries
  }
}

extension _AHAPEventParameters {
  public init(dictionaryLiteral elements: (ID, Double)...) {
    self.init()
    self.entries = [ID: Double](uniqueKeysWithValues: elements)
  }
}

extension _AHAPEventParameters {
  public subscript(id: ID) -> Double? {
    get { self.entries[id] }
    set {
      if let newValue {
        self.entries[id] = newValue
      } else {
        self.entries.removeValue(forKey: id)
      }
    }
  }
}

// MARK: - Parameter Curve

extension AHAPPattern {
  public struct ParameterCurve: Hashable, Sendable {
    public var id: CurvableParameterID
    public var time: Double
    public var controlPoints: [ControlPoint]

    public init(
      id: AHAPPattern.CurvableParameterID,
      time: Double,
      controlPoints: [AHAPPattern.ParameterCurve.ControlPoint]
    ) {
      self.id = id
      self.time = time
      self.controlPoints = controlPoints
    }
  }
}

extension AHAPPattern.ParameterCurve: Codable {
  private enum CodingKeys: String, CodingKey {
    case id = "ParameterID"
    case time = "Time"
    case controlPoints = "ParameterCurveControlPoints"
  }
}

// MARK: - Curvable Parameter ID

extension AHAPPattern {
  public enum CurvableParameterID: String, Hashable, Sendable, Codable {
    case hapticIntensityControl = "HapticIntensityControl"
    case hapticSharpnessControl = "HapticSharpnessControl"
    case audioVolumeControl = "AudioVolumeControl"
    case audioPanControl = "AudioPanControl"
    case audioBrightnessControl = "AudioBrightnessControl"
    case audioPitchControl = "AudioPitchControl"
  }
}

// MARK: - Parameter Curve Control Point

extension AHAPPattern.ParameterCurve {
  public struct ControlPoint: Hashable, Sendable {
    public var time: Double
    public var value: Double

    public init(time: Double, value: Double) {
      self.time = time
      self.value = value
    }
  }
}

extension AHAPPattern.ParameterCurve.ControlPoint: Codable {
  private enum CodingKeys: String, CodingKey {
    case time = "Time"
    case value = "ParameterValue"
  }
}

// MARK: - Dynamic Parameter

extension AHAPPattern {
  public struct DynamicParameter: Hashable, Sendable {
    public var id: DynamicParameterID
    public var time: Double
    public var value: Double

    public init(id: AHAPPattern.DynamicParameterID, time: Double, value: Double) {
      self.id = id
      self.time = time
      self.value = value
    }
  }
}

extension AHAPPattern.DynamicParameter: Codable {
  private enum CodingKeys: String, CodingKey {
    case id = "ParameterID"
    case time = "Time"
    case value = "ParameterValue"
  }
}

// MARK: - Dynamic Parameter ID

extension AHAPPattern {
  public enum DynamicParameterID: String, Codable, Equatable, Sendable {
    case hapticIntensityControl = "HapticIntensityControl"
    case hapticSharpnessControl = "HapticSharpnessControl"
    case hapticAttackTimeControl = "HapticAttackTimeControl"
    case hapticDecayTimeControl = "HapticDecayTimeControl"
    case hapticReleaseTimeControl = "HapticReleaseTimeControl"
    case audioVolumeControl = "AudioVolumeControl"
    case audioPanControl = "AudioPanControl"
    case audioBrightnessControl = "AudioBrightnessControl"
    case audioPitchControl = "AudioPitchControl"
    case audioAttackTimeControl = "AudioAttackTimeControl"
    case audioDecayTimeControl = "AudioDecayTimeControl"
    case audioReleaseTimeControl = "AudioReleaseTimeControl"
  }
}

// MARK: - Serialized Parameter

private struct SerializedParameter {
  let id: String
  let value: Double
}

extension SerializedParameter: Codable {
  private enum CodingKeys: String, CodingKey {
    case id = "ParameterID"
    case value = "ParameterValue"
  }
}
