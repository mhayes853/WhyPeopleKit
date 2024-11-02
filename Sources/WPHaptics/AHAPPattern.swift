import Foundation

// MARK: - AHAPPattern

/// A value type for an AHAP pattern that can be played by CoreHaptics.
///
/// This value type allows type-safe and cross-platform creation of AHAP patterns in environments
/// that cannot import CoreHaptics such as on a linux server.
///
/// This type conforms to Hashable, Sendable, and Codable, which allows AHAP patterns to be easily
/// compared for equality, passed between threads, and parsed from raw data unlike the types
/// specified by the CoreHaptics framework. You can also use ``data(format:)`` and ``init(from:)-7365y``
/// to export and convert a pattern from raw AHAP data as well.
public struct AHAPPattern: Hashable, Sendable {
  /// The numerical version of this pattern.
  public var version: Int

  /// The elements in this pattern.
  public var elements: [Element]

  /// Creates an AHAP pattern.
  ///
  /// - Parameters:
  ///   - version: The numerical version of this pattern.
  ///   - elements: The elements in this pattern.
  public init(version: Int = 1, elements: [AHAPPattern.Element]) {
    self.version = version
    self.elements = elements
  }
}

extension AHAPPattern {
  /// Creates an AHAP pattern.
  ///
  /// - Parameters:
  ///   - version: The numerical version of this pattern.
  ///   - elements: The elements in this pattern.
  public init(version: Int = 1, _ elements: Element...) {
    self.init(version: version, elements: Array(elements))
  }
}

extension AHAPPattern: Codable {
  private enum CodingKeys: String, CodingKey {
    case version = "Version"
    case elements = "Pattern"
  }
}

// MARK: - Data Functions

extension AHAPPattern {
  /// An output format for the AHAP data of this pattern.
  public enum DataOutputFormat {
    /// A format that outputs prettyfied json with lexographically ordered keys.
    case prettyJson

    /// A format that outputs raw unformatted json.
    case json
  }

  /// Returns raw AHAP data for this pattern.
  ///
  /// - Parameter format: The ``DataOutputFormat`` to use.
  public func data(format: DataOutputFormat = .json) -> Data {
    let encoder = JSONEncoder()
    if format == .prettyJson {
      encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    }
    return try! encoder.encode(self)
  }

  /// Attempts to create a pattern from raw AHAP data.
  ///
  /// - Parameter data: Raw AHAP formatted data.
  public init(from data: Data) throws {
    self = try JSONDecoder().decode(Self.self, from: data)
  }
}

// MARK: - IO Functions

extension AHAPPattern {
  /// Writes the raw AHAP data of this pattern to the specified `URL`.
  ///
  /// - Parameters:
  ///   - url: The `URL` to write the pattern data to.
  ///   - format: The ``DataOutputFormat`` to use.
  ///   - options: Options for writing the data. Default value is `[]`.
  public func write(
    to url: URL,
    format: DataOutputFormat = .json,
    options: Data.WritingOptions = []
  ) throws {
    try self.data(format: format).write(to: url, options: options)
  }

  /// Attempts to create a pattern from the raw AHAP data from the specified `URL`.
  ///
  /// - Parameters:
  ///   - url: The `URL` of where the raw AHAP data is located.
  ///   - options: Options for reading the data. Default value is `[]`.
  public init(contentsOf url: URL, options: Data.ReadingOptions = []) throws {
    try self.init(from: Data(contentsOf: url, options: options))
  }
}

// MARK: - Element

extension AHAPPattern {
  /// An element of an AHAP pattern.
  public enum Element: Hashable, Sendable {
    /// A pattern element for a haptic or audio event.
    ///
    /// Events can either be continuous or transient. Continuous events play for a specified
    /// duration whilst transient events play instantaneuously.
    case event(Event)

    /// A pattern element for a parameter curve.
    ///
    /// Parameter curves allow interpolations of parameter values over a specified length of time
    /// during an event using control points in the same way that key frames are used to
    /// interpolate points between animations. For instantly changing a parameter value at a
    /// certain point in time, use ``dynamicParameter(_:)``.
    case parameterCurve(ParameterCurve)

    /// A pattern element for a dynamic parameter.
    ///
    /// Dyanmic parameters instantly change the parameter value at a specified time during an
    /// event. If you want to interpolate the value over time instead of changing it instantly, use
    /// ``parameterCurve(_:)``.
    case dynamicParameter(DynamicParameter)
  }
}

extension AHAPPattern.Element {
  /// Creates a parameter curve pattern element.
  ///
  /// Parameter curves allow interpolations of parameter values over a specified length of time
  /// during an event using control points in the same way that key frames are used to
  /// interpolate points between animations. For instantly changing a parameter value at a
  /// certain point in time, use ``dynamicParameter(id:time:value:)``.
  ///
  /// - Parameters:
  ///   - id: The parameter is of this parameter curve.
  ///   - time: The time at which this parameter curve starts in a pattern.
  ///   - controlPoints: The control points of this parameter curve.
  /// - Returns: A patten element.
  public static func parameterCurve(
    id: AHAPPattern.CurvableParameterID,
    time: Double,
    controlPoints: [AHAPPattern.ParameterCurve.ControlPoint]
  ) -> Self {
    .parameterCurve(AHAPPattern.ParameterCurve(id: id, time: time, controlPoints: controlPoints))
  }

  /// Creates a dynamic parameter pattern element.
  ///
  /// Dyanmic parameters instantly change the parameter value at a specified time during an
  /// event. If you want to interpolate the value over time instead of changing it instantly, use
  /// ``parameterCurve(id:time:controlPoints:)``.
  ///
  /// - Parameters:
  ///   - id: The parameter id of this dynamic parameter.
  ///   - time: The time at which this parameter takes effect in a pattern.
  ///   - value: The value to set the parameter to.
  /// - Returns: A patten element.
  public static func dynamicParameter(
    id: AHAPPattern.DynamicParameterID,
    time: Double,
    value: Double
  ) -> Self {
    .dynamicParameter(AHAPPattern.DynamicParameter(id: id, time: time, value: value))
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
  /// An AHAP pattern event.
  public enum Event: Hashable, Sendable {
    /// A transient haptic event.
    ///
    /// Transient haptic events play haptic feedback instantaneously in time. For playing haptic
    /// feedback for a specified duration, use ``hapticContinuous(_:)``.
    ///
    /// This event is mostly useful for providing instant feedback from user actions such as
    /// tapping a button.
    case hapticTransient(HapticTransientEvent)

    /// A continuous haptic event.
    ///
    /// Continuous haptic events play haptic feedback for a specified duration of time. For
    /// instantaneously playing haptic feedback, use ``hapticTransient(_:)``.
    ///
    /// This event is mostly useful for non-direct feedback actions such as holding down a UI
    /// element during an animation, or for adding emphasis to a collision of 2 or more objects.
    ///
    /// The maximum playback time of a continuous haptic event is 30 seconds.
    case hapticContinuous(HapticContinuousEvent)

    /// A custom audio event.
    ///
    /// Custom audio events play a waveform of your choosing for its entire duration. For
    /// looping a sound effect for a specified duration of time, use ``audioContinuous(_:)``.
    case audioCustom(AudioCustomEvent)

    /// A continuous audio event.
    ///
    /// Continuous audio events can loop a sound effect for a specified duration of time. For
    /// playing a waveform in its entirety without looping, use ``audioCustom(_:)``.
    case audioContinuous(AudioContinuousEvent)
  }
}

extension AHAPPattern.Event {
  /// Creates a transient haptic event.
  ///
  /// Transient haptic events play haptic feedback instantaneously in time. For playing haptic
  /// feedback for a specified duration, use ``hapticContinuous(time:duration:parameters:)``.
  ///
  /// This event is mostly useful for providing instant feedback from user actions such as
  /// tapping a button.
  ///
  /// - Parameters:
  ///   - time: The time this event plays at relative to other events in a pattern.
  ///   - parameters: The parameters of this event.
  /// - Returns: A transient haptic event.
  public static func hapticTransient(
    time: Double,
    parameters: AHAPPattern.HapticParameters
  ) -> Self {
    .hapticTransient(AHAPPattern.HapticTransientEvent(time: time, parameters: parameters))
  }

  /// Creates a continuous haptic event.
  ///
  /// Continuous haptic events play haptic feedback for a specified duration of time. For
  /// instantaneously playing haptic feedback, use ``hapticTransient(time:parameters:)``.
  ///
  /// This event is mostly useful for non-direct feedback actions such as holding down a UI
  /// element during an animation, or for adding emphasis to a collision of 2 or more objects.
  ///
  /// The maximum playback time of a continuous haptic event is 30 seconds.
  ///
  /// - Parameters:
  ///   - time: The time this event plays at relative to other events in a pattern.
  ///   - duration: The duration of how long this event plays for.
  ///   - parameters: The parameters of this event.
  /// - Returns: A continuous haptic event.
  public static func hapticContinuous(
    time: Double,
    duration: Double,
    parameters: AHAPPattern.HapticParameters
  ) -> Self {
    .hapticContinuous(
      AHAPPattern.HapticContinuousEvent(time: time, duration: duration, parameters: parameters)
    )
  }

  /// Creates a custom audio event.
  ///
  /// Custom audio events play a waveform of your choosing for its entire duration. For
  /// looping a sound effect for a specified duration of time, use
  ///  ``audioContinuous(time:duration:waveformPath:waveformLoopEnabled:waveformUseVolumeEnvelope:parameters:)``.
  ///
  /// - Parameters:
  ///   - time: The time this event plays at relative to other events in a pattern.
  ///   - waveformPath: The file path of the waveform.
  ///   - waveformLoopEnabled: Whether or not to loop the waveform.
  ///   - waveformUseVolumeEnvelope: Whether or not the waveform audio fades in and out with an envelope.
  ///   - duration: The duration of how long this event plays for.
  ///   - parameters: The parameters of this event.
  /// - Returns: A custom audio event.
  public static func audioCustom(
    time: Double,
    waveformPath: String,
    waveformLoopEnabled: Bool = false,
    waveformUseVolumeEnvelope: Bool = false,
    duration: Double? = nil,
    parameters: AHAPPattern.AudioParameters = AHAPPattern.AudioParameters()
  ) -> Self {
    .audioCustom(
      AHAPPattern.AudioCustomEvent(
        time: time,
        waveformPath: waveformPath,
        waveformLoopEnabled: waveformLoopEnabled,
        waveformUseVolumeEnvelope: waveformUseVolumeEnvelope,
        duration: duration,
        parameters: parameters
      )
    )
  }

  /// Creates a continuous audio event.
  ///
  /// Continuous audio events can loop a sound effect for a specified duration of time. For
  /// playing a waveform in its entirety without looping, use
  /// ``audioCustom(time:waveformPath:waveformLoopEnabled:waveformUseVolumeEnvelope:parameters:)``.
  ///
  /// - Parameters:
  ///   - time: The time this event plays at relative to other events in a pattern.
  ///   - duration: The duration of how long this event plays for.
  ///   - waveformUseVolumeEnvelope: Whether or not the waveform audio fades in and out with an envelope.
  ///   - parameters: The parameters of this event.
  /// - Returns: A continuous audio event.
  public static func audioContinuous(
    time: Double,
    duration: Double,
    waveformUseVolumeEnvelope: Bool = false,
    parameters: AHAPPattern.AudioParameters = AHAPPattern.AudioParameters()
  ) -> Self {
    .audioContinuous(
      AHAPPattern.AudioContinuousEvent(
        time: time,
        duration: duration,
        waveformUseVolumeEnvelope: waveformUseVolumeEnvelope,
        parameters: parameters
      )
    )
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
  /// An enum value for an event type.
  ///
  /// Events can either be continuous or transient. Continuous events play for a specified
  /// duration whilst transient events play instantaneuously.
  public enum EventType: String, Hashable, Sendable, Codable {
    /// A transient haptic event type.
    ///
    /// Transient haptic events play haptic feedback instantaneously in time. For playing haptic
    /// feedback for a specified duration, use ``hapticContinuous``.
    ///
    /// This event type is mostly useful for providing instant feedback from user actions such as
    /// tapping a button.
    case hapticTransient = "HapticTransient"

    /// A continuous haptic event type.
    ///
    /// Continuous haptic events play haptic feedback for a specified duration of time. For
    /// instantaneously playing haptic feedback, use ``hapticTransient``.
    ///
    /// This event type is mostly useful for non-direct feedback actions such as holding down a UI
    /// element during an animation, or for adding emphasis to a collision of 2 or more objects.
    ///
    /// The maximum playback time of a continuous haptic event is 30 seconds.
    case hapticContinuous = "HapticContinuous"

    /// A custom audio event type.
    ///
    /// Custom audio events play a waveform of your choosing for its entire duration. For
    /// looping a sound effect for a specified duration of time, use ``audioContinuous``.
    case audioContinuous = "AudioContinuous"

    /// A continuous audio event type.
    ///
    /// Continuous audio events can loop a sound effect for a specified duration of time. For
    /// playing a waveform in its entirety without looping, use ``audioCustom``.
    case audioCustom = "AudioCustom"
  }
}

// MARK: - Transient Event

extension AHAPPattern {
  /// A transient haptic event.
  ///
  /// Transient haptic events play haptic feedback instantaneously in time. For playing haptic
  /// feedback for a specified duration, use ``HapticContinuousEvent``.
  ///
  /// This event is mostly useful for providing instant feedback from user actions such as
  /// tapping a button.
  public struct HapticTransientEvent: Hashable, Sendable {
    private var eventType = EventType.hapticTransient

    /// The time this event plays at relative to other events in a pattern.
    public var time: Double

    /// The parameters of this event.
    public var parameters: HapticParameters

    /// Creates a haptic transient event.
    ///
    /// - Parameters:
    ///   - time: The time this event plays at relative to other events in a pattern.
    ///   - parameters: The parameters of this event.
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
  /// A continuous haptic event.
  ///
  /// Continuous haptic events play haptic feedback for a specified duration of time. For
  /// instantaneously playing haptic feedback, use ``HapticTransientEvent``.
  ///
  /// This event is mostly useful for non-direct feedback actions such as holding down a UI
  /// element during an animation, or for adding emphasis to a collision of 2 or more objects.
  ///
  /// The maximum playback time of a continuous haptic event is 30 seconds.
  public struct HapticContinuousEvent: Hashable, Sendable {
    private var eventType = EventType.hapticContinuous

    /// The time this event plays at relative to other events in a pattern.
    public var time: Double

    /// The duration of how long this event plays for.
    public var duration: Double

    /// The parameters of this event.
    public var parameters: HapticParameters

    /// Creates a haptic continuous event.
    ///
    /// - Parameters:
    ///   - time: The time this event plays at relative to other events in a pattern.
    ///   - duration: The duration of how long this event plays for.
    ///   - parameters: The parameters of this event.
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
  /// Parameters for use in haptic events.
  public struct HapticParameters: AHAPPattern.EventParameters {
    public var entries = [HapticParameterID: Double]()
    public init() {}
  }
}

// MARK: - Haptic Parameter ID

extension AHAPPattern {
  /// Parameter ids for haptic events.
  public enum HapticParameterID: String, Hashable, Sendable, Codable {
    /// The intensity of a haptic event.
    ///
    /// The intensity specifies how much strength that the haptic engine must use in a given event.
    /// A higher intensity causes a stronger and emphasized vibration, whilst a lower intensity
    /// causes a weaker and subtler vibration.
    ///
    /// This parameter value ranges from 0.0 (weak) to 1.0 (strong).
    case hapticIntensity = "HapticIntensity"

    /// The sharpness of a haptic event.
    ///
    /// The sharpness specifies how the vibration of a haptic event is dispersed in the area of a
    /// surface such as the palm of your hand. A lower sharpness will produce a round-feeling
    /// vibration to a large area whereas a high sharpness will produce a focused vibration to a
    /// small area.
    ///
    /// This parameter value ranges from 0.0 (round) to 1.0 (focused).
    case hapticSharpness = "HapticSharpness"

    /// The attack time of a haptic event.
    ///
    /// The attack time of an event refers to the duration (in seconds) of build-up before an event
    /// reaches its peak intensity.
    ///
    /// This parameter value ranges from -1.0 (exponential decrease) to 1.0 (exponential increase).
    case attackTime = "AttackTime"

    /// The decay time of a haptic event.
    ///
    /// The attack time of an event refers to the duration (in seconds) of burn-down after an
    /// event reaches its peak intensity.
    ///
    /// This parameter value ranges from -1.0 (exponential decrease) to 1.0 (exponential increase).
    case decayTime = "DecayTime"

    /// The release time (in seconds) of a haptic event.
    ///
    /// The release time adds a fade-out effect to the haptic event.
    ///
    /// This parameter value must be 0 or greater.
    case releaseTime = "ReleaseTime"

    /// Whether or not to sustain a haptic event for its entire duration.
    ///
    /// When true, the haptic pattern stays at full strength between the ``attackTime`` and the
    /// ``decayTime``. Otherwise, it never reaches full strength and begins tailing off even before
    /// the decay time has begun.
    case sustained = "Sustained"
  }
}

// MARK: - Audio Custom Event

extension AHAPPattern {
  /// A custom audio event.
  ///
  /// Custom audio events play a waveform of your choosing for its entire duration. For
  /// looping a sound effect for a specified duration of time, use ``AudioContinuousEvent``
  public struct AudioCustomEvent: Hashable, Sendable {
    private var eventType = EventType.audioCustom

    /// The time this event plays at relative to other events in a pattern.
    public var time: Double

    /// The file path of the waveform.
    public var waveformPath: String

    /// Whether or not to loop the waveform.
    public var waveformLoopEnabled = false

    /// Whether or not the waveform audio fades in and out with an envelope.
    public var waveformUseVolumeEnvelope = false

    /// The duration of how long this event plays for.
    public var duration: Double?

    /// The parameters of this event.
    public var parameters = AudioParameters()

    /// Creates an audio custom event.
    ///
    /// - Parameters:
    ///   - time: The time this event plays at relative to other events in a pattern.
    ///   - waveformPath: The file path of the waveform.
    ///   - waveformLoopEnabled: Whether or not to loop the waveform.
    ///   - waveformUseVolumeEnvelope: Whether or not the waveform audio fades in and out with an envelope.
    ///   - duration: The duration of how long this event plays for.
    ///   - parameters: The parameters of this event.
    public init(
      time: Double,
      waveformPath: String,
      waveformLoopEnabled: Bool = false,
      waveformUseVolumeEnvelope: Bool = false,
      duration: Double? = nil,
      parameters: AudioParameters = AudioParameters()
    ) {
      self.time = time
      self.waveformPath = waveformPath
      self.waveformLoopEnabled = waveformLoopEnabled
      self.waveformUseVolumeEnvelope = waveformUseVolumeEnvelope
      self.duration = duration
      self.parameters = parameters
    }
  }
}

extension AHAPPattern.AudioCustomEvent: Encodable {
  public func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(self.eventType, forKey: .eventType)
    try container.encode(self.time, forKey: .time)
    try container.encode(self.waveformPath, forKey: .waveformPath)
    try container.encode(self.waveformLoopEnabled, forKey: .waveformLoopEnabled)
    try container.encode(self.waveformUseVolumeEnvelope, forKey: .waveformUseVolumeEnvelope)
    try container.encode(self.parameters, forKey: .parameters)
    try container.encodeIfPresent(self.duration, forKey: .duration)
  }
}

extension AHAPPattern.AudioCustomEvent: Decodable {
  public init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.time = try container.decode(Double.self, forKey: .time)
    self.waveformPath = try container.decode(String.self, forKey: .waveformPath)
    self.parameters = try container.decode(AHAPPattern.AudioParameters.self, forKey: .parameters)
    self.duration = try container.decodeIfPresent(Double.self, forKey: .duration)
    self.waveformLoopEnabled =
      try container.decodeIfPresent(Bool.self, forKey: .waveformLoopEnabled) ?? false
    self.waveformUseVolumeEnvelope =
      try container.decodeIfPresent(Bool.self, forKey: .waveformUseVolumeEnvelope) ?? false
  }
}

extension AHAPPattern.AudioCustomEvent {
  private enum CodingKeys: String, CodingKey {
    case eventType = "EventType"
    case time = "Time"
    case duration = "EventDuration"
    case waveformPath = "EventWaveformPath"
    case waveformLoopEnabled = "EventWaveformLoopEnabled"
    case waveformUseVolumeEnvelope = "EventWaveformUseVolumeEnvelope"
    case parameters = "EventParameters"
  }
}

// MARK: - Audio Continuous Event

extension AHAPPattern {
  /// A continuous audio event.
  ///
  /// Continuous audio events can loop a sound effect for a specified duration of time. For
  /// playing a waveform in its entirety without looping, use ``AudioCustomEvent``
  public struct AudioContinuousEvent: Hashable, Sendable {
    private var eventType = EventType.audioContinuous

    /// The time this event plays at relative to other events in a pattern.
    public var time: Double

    /// The duration of how long this event plays for.
    public var duration: Double

    /// Whether or not the waveform audio fades in and out with an envelope.
    public var waveformUseVolumeEnvelope = false

    /// The parameters of this event.
    public var parameters = AudioParameters()

    /// Creates an audio continuous event.
    ///
    /// - Parameters:
    ///   - time: The time this event plays at relative to other events in a pattern.
    ///   - duration: The duration of how long this event plays for.
    ///   - waveformUseVolumeEnvelope: Whether or not the waveform audio fades in and out with an envelope.
    ///   - parameters: The parameters of this event.
    public init(
      time: Double,
      duration: Double,
      waveformUseVolumeEnvelope: Bool = false,
      parameters: AudioParameters = AudioParameters()
    ) {
      self.time = time
      self.duration = duration
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
    case waveformUseVolumeEnvelope = "EventWaveformUseVolumeEnvelope"
    case parameters = "EventParameters"
  }
}

extension AHAPPattern.AudioContinuousEvent: Decodable {
  public init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.time = try container.decode(Double.self, forKey: .time)
    self.duration = try container.decode(Double.self, forKey: .duration)
    self.parameters = try container.decode(AHAPPattern.AudioParameters.self, forKey: .parameters)
    self.waveformUseVolumeEnvelope =
      try container.decodeIfPresent(Bool.self, forKey: .waveformUseVolumeEnvelope) ?? false
  }
}

// MARK: - Audio Parameters

extension AHAPPattern {
  /// Parameters for use in audio events.
  public struct AudioParameters: AHAPPattern.EventParameters {
    public var entries = [AudioParameterID: Double]()
    public init() {}
  }
}

// MARK: - Audio Parameter ID

extension AHAPPattern {
  /// Parameter ids for audio events.
  public enum AudioParameterID: String, Hashable, Sendable, Codable {
    /// The volume of an audio event.
    ///
    /// This parameter value ranges from 0.0 (silent) to 1.0 (maximum volume).
    case audioVolume = "AudioVolume"

    /// The pitch of an audio event.
    ///
    /// This parameter value ranges from -1.0 (lowest pitch) to 1.0 (highest pitch).
    case audioPitch = "AudioPitch"

    /// The stereo panning of an audio event.
    ///
    /// This parameter value ranges from -1.0 (panned hard left) to 1.0 (panned hard right). The
    /// default value is 0.0 (center panned).
    case audioPan = "AudioPan"

    /// The high-frequency content of an audio event.
    ///
    /// This parameter value ranges from 0.0 (maximum high-frequency reduction) to 1.0 (no
    /// high-frequency reduction). The default value is 1.0.
    case audioBrightness = "AudioBrightness"
  }
}

// MARK: - Event Parameters

extension AHAPPattern {
  /// A protocol for a set of parameters for a pattern event.
  ///
  /// You should not need to conform to this protocol, rather you can use it as a generic
  /// constraint on code that generically uses ``HapticParameters`` and ``AudioParameters``.
  public protocol EventParameters<ID>: Codable, Hashable, Sendable,
    ExpressibleByDictionaryLiteral
  {
    associatedtype ID: Hashable, RawRepresentable where ID.RawValue == String

    /// A dictionary of parameter ids to values.
    var entries: [ID: Double] { get set }

    /// Creates an empty set of parameters.
    init()
  }
}

extension AHAPPattern.EventParameters {
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

extension AHAPPattern.EventParameters {
  /// Creates a set of parameters from the specified entries.
  ///
  /// - Parameter entries: A dictionary of parameter ids to parameter values.
  public init(_ entries: [ID: Double]) {
    self.init()
    self.entries = entries
  }
}

extension AHAPPattern.EventParameters {
  public init(dictionaryLiteral elements: (ID, Double)...) {
    self.init()
    self.entries = [ID: Double](uniqueKeysWithValues: elements)
  }
}

extension AHAPPattern.EventParameters {
  /// The parameter value for the specified parameter id.
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
  /// An AHAP pattern parameter curve.
  ///
  /// Paramater curves allow interpolations of parameter values over a specified length of time
  /// during an event using control points in the same way that key frames are used to
  /// interpolate points between animations. For instantly changing a parameter value at a
  /// certain point in time, use ``DynamicParameter``.
  public struct ParameterCurve: Hashable, Sendable {
    /// The parameter is of this parameter curve.
    public var id: CurvableParameterID

    /// The time at which this parameter curve starts in a pattern.
    public var time: Double

    /// The control points of this parameter curve.
    public var controlPoints: [ControlPoint]

    /// Creates a parameter curve.
    ///
    /// - Parameters:
    ///   - id: The parameter is of this parameter curve.
    ///   - time: The time at which this parameter curve starts in a pattern.
    ///   - controlPoints: The control points of this parameter curve.
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
  /// Parameter ids that can be used in parameter curves.
  public enum CurvableParameterID: String, Hashable, Sendable, Codable {
    /// The intensity of a haptic event.
    ///
    /// The intensity specifies how much strength that the haptic engine must use in a given event.
    /// A higher intensity causes a stronger and emphasized vibration, whilst a lower intensity
    /// causes a weaker and subtler vibration.
    ///
    /// This parameter value ranges from 0.0 (weak) to 1.0 (strong).
    case hapticIntensityControl = "HapticIntensityControl"

    /// The sharpness of a haptic event.
    ///
    /// The sharpness specifies how the vibration of a haptic event is dispersed in the area of a
    /// surface such as the palm of your hand. A lower sharpness will produce a round-feeling
    /// vibration to a large area whereas a high sharpness will produce a focused vibration to a
    /// small area.
    ///
    /// This parameter value ranges from 0.0 (round) to 1.0 (focused).
    case hapticSharpnessControl = "HapticSharpnessControl"

    /// The volume of an audio event.
    ///
    /// This parameter value ranges from 0.0 (silent) to 1.0 (maximum volume).
    case audioVolumeControl = "AudioVolumeControl"

    /// The stereo panning of an audio event.
    ///
    /// This parameter value ranges from -1.0 (panned hard left) to 1.0 (panned hard right). The
    /// default value is 0.0 (center panned).
    case audioPanControl = "AudioPanControl"

    /// The high-frequency content of an audio event.
    ///
    /// This parameter value ranges from 0.0 (maximum high-frequency reduction) to 1.0 (no
    /// high-frequency reduction). The default value is 1.0.
    case audioBrightnessControl = "AudioBrightnessControl"

    /// The pitch of an audio event.
    ///
    /// This parameter value ranges from -1.0 (lowest pitch) to 1.0 (highest pitch).
    case audioPitchControl = "AudioPitchControl"
  }
}

// MARK: - Parameter Curve Control Point

extension AHAPPattern.ParameterCurve {
  /// A control point for an AHAP pattern parameter curve.
  ///
  /// A control point is like a key frame in an animation, it specifies what the parameter value
  /// should be at a point in time, and the parameter curve will interpolate to that value between
  /// control points.
  public struct ControlPoint: Hashable, Sendable {
    /// The time at which this control point takes full effect.
    public var time: Double

    /// The parameter value at the point in time that this contol point takes full effect.
    public var value: Double

    /// Creates a control point.
    ///
    /// - Parameters:
    ///   - time: The time at which this control point takes full effect.
    ///   - value: The parameter value at the point in time that this contol point takes full effect.
    public init(time: Double, value: Double) {
      self.time = time
      self.value = value
    }
  }
}

extension AHAPPattern.ParameterCurve.ControlPoint {
  /// Creates a control point.
  ///
  /// - Parameters:
  ///   - time: The time at which this control point takes full effect.
  ///   - value: The parameter value at the point in time that this contol point takes full effect.
  /// - Returns: A control point.
  public static func point(time: Double, value: Double) -> Self {
    Self(time: time, value: value)
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
  /// An AHAP pattern dynamic parameter.
  ///
  /// Dyanmic parameters instantly change the parameter value at a specified time during an
  /// event. If you want to interpolate the value over time instead of changing it instantly, use
  /// ``ParameterCurve``.
  public struct DynamicParameter: Hashable, Sendable {
    /// The parameter id of this dynamic parameter.
    public var id: DynamicParameterID

    /// The time at which this parameter takes effect in a pattern.
    public var time: Double

    /// The value to set the parameter to.
    public var value: Double

    /// Creates a dynamic parameter.
    ///
    /// - Parameters:
    ///   - id: The parameter id of this dynamic parameter.
    ///   - time: The time at which this parameter takes effect in a pattern.
    ///   - value: The value to set the parameter to.
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
  /// Parameter ids that can be used with dynamic parameters.
  public enum DynamicParameterID: String, Codable, Equatable, Sendable {
    /// The intensity of a haptic event.
    ///
    /// The intensity specifies how much strength that the haptic engine must use in a given event.
    /// A higher intensity causes a stronger and emphasized vibration, whilst a lower intensity
    /// causes a weaker and subtler vibration.
    ///
    /// This parameter value ranges from 0.0 (weak) to 1.0 (strong).
    case hapticIntensityControl = "HapticIntensityControl"

    /// The sharpness of a haptic event.
    ///
    /// The sharpness specifies how the vibration of a haptic event is dispersed in the area of a
    /// surface such as the palm of your hand. A lower sharpness will produce a round-feeling
    /// vibration to a large area whereas a high sharpness will produce a focused vibration to a
    /// small area.
    ///
    /// This parameter value ranges from 0.0 (round) to 1.0 (focused).
    case hapticSharpnessControl = "HapticSharpnessControl"

    /// The attack time of a haptic event.
    ///
    /// The attack time of an event refers to the duration (in seconds) of build-up before an event
    /// reaches its peak intensity.
    ///
    /// This parameter value ranges from -1.0 (exponential decrease) to 1.0 (exponential increase).
    case hapticAttackTimeControl = "HapticAttackTimeControl"

    /// The decay time of a haptic event.
    ///
    /// The attack time of an event refers to the duration (in seconds) of burn-down after an
    /// event reaches its peak intensity.
    ///
    /// This parameter value ranges from -1.0 (exponential decrease) to 1.0 (exponential increase).
    case hapticDecayTimeControl = "HapticDecayTimeControl"

    /// The release time (in seconds) of a haptic event.
    ///
    /// The release time adds a fadeout effect to the haptic event.
    ///
    /// This parameter value must be 0 or greater.
    case hapticReleaseTimeControl = "HapticReleaseTimeControl"

    /// The volume of an audio event.
    ///
    /// This parameter value ranges from 0.0 (silent) to 1.0 (maximum volume).
    case audioVolumeControl = "AudioVolumeControl"

    /// The stereo panning of an audio event.
    ///
    /// This parameter value ranges from -1.0 (panned hard left) to 1.0 (panned hard right). The
    /// default value is 0.0 (center panned).
    case audioPanControl = "AudioPanControl"

    /// The high-frequency content of an audio event.
    ///
    /// This parameter value ranges from 0.0 (maximum high-frequency reduction) to 1.0 (no
    /// high-frequency reduction). The default value is 1.0.
    case audioBrightnessControl = "AudioBrightnessControl"

    /// The pitch of an audio event.
    ///
    /// This parameter value ranges from -1.0 (lowest pitch) to 1.0 (highest pitch).
    case audioPitchControl = "AudioPitchControl"

    /// The attack time of an audio event.
    ///
    /// The attack time of an event refers to the duration (in seconds) of build-up before the
    /// audio signal amplitude reaches its peak value.
    case audioAttackTimeControl = "AudioAttackTimeControl"

    /// The decay time of an audio event.
    ///
    /// The attack time of an event refers to the duration (in seconds) of burn-down after the
    /// audio signal amplitude reaches its peak value.
    case audioDecayTimeControl = "AudioDecayTimeControl"

    /// The release time (in seconds) of an audio event.
    ///
    /// The release time adds a fade-out effect to the audio signal.
    ///
    /// This parameter value must be 0 or greater.
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
