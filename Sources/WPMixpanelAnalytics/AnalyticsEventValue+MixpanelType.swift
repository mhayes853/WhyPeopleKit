#if canImport(Mixpanel)
  import Foundation
  import Mixpanel
  import WPAnalyticsCore

  // MARK: - Event Type

  extension AnalyticsEvent.Value {
    /// This value as a `MixpanelType`.
    ///
    /// All nested nil values are represented as `NSNull`.
    public var mixpanelType: any MixpanelType {
      switch self {
      case let .integer(i): Int(truncatingIfNeeded: i)
      case let .unsignedInteger(i): UInt(truncatingIfNeeded: i)
      case let .boolean(b): b
      case let .date(d): d
      case let .double(d): d
      case let .url(u): u
      case let .string(s): s
      case let .array(a): a.map(\.mixpanelType)
      case let .dict(d): d.mapValues(\.mixpanelType)
      }
    }
  }

  // MARK: - Dictionary Properties

  extension Dictionary where Key == String, Value == AnalyticsEvent.Value? {
    /// This dictionary as a mixpanel properties dictionary.
    ///
    /// Any nil values are repesented as `NSNull` in the resulting properties.
    public var mixpanelProperties: Properties {
      self.mapValues(\.mixpanelType)
    }
  }

  extension Dictionary where Key == String, Value == AnalyticsEvent.Value {
    /// This dictionary as a mixpanel properties dictionary.
    ///
    /// Any nil values are repesented as `NSNull` in the resulting properties.
    public var mixpanelProperties: Properties {
      self.mapValues(\.mixpanelType)
    }
  }

  // MARK: - Optional Type

  extension AnalyticsEvent.Value? {
    /// This value as a `MixpanelType`.
    ///
    /// If this value is nil, then `NSNull` is returned.
    public var mixpanelType: any MixpanelType {
      self?.mixpanelType ?? NSNull()
    }
  }
#endif
