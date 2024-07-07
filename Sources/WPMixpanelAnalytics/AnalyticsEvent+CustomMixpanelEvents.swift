import Mixpanel
import WPAnalyticsCore

// MARK: - Increment

extension AnalyticsEvent {
  /// An event to increment multiple properties with the specified dictionary keys by the amount
  /// specified by the value for each dictionary key.
  ///
  /// - Parameter properties: A dictionary of properties and with the amount to increment the
  /// property by.
  /// - Returns: An event to increment multiple properties.
  public static func increment(properties: [String: Double]) -> Self {
    .mixpanel { $0.people.increment(properties: properties) }
  }
}

// MARK: - Time

extension AnalyticsEvent {
  /// An event that starts a timer that is stopped by when a corresponding event name is recorded.
  /// 
  /// ```swift
  /// func recordOperationPerformance(_ recorder: some AnaltyicsRecorder) {
  ///   recorder.record(event: .time(name: "operation"))
  ///   runOperation()
  ///   recorder.record(name: "operation") // Stops the timer
  /// }
  /// ```
  /// - Parameter name: The name of the event to associate with the timer.
  /// - Returns: An event that starts a timer.
  public static func time(name: String) -> Self {
    .mixpanel { $0.time(event: name) }
  }
  
  /// An event that clears the timer for an event returned by ``time(name:)``.
  ///
  /// - Parameter name: The name of the event that was associated with the timer.
  /// - Returns: An event that clears a timer.
  public static func clearTime(name: String) -> Self {
    .mixpanel { $0.clearTimedEvent(event: name) }
  }
  
  /// An event that clears all timers for events returned by ``time(name:)``.
  public static let clearAllTimers = Self.mixpanel { $0.clearTimedEvents() }
}

// MARK: - Super Properties

extension AnalyticsEvent {
  /// An event that registers the specified dictionary of super properties.
  ///
  /// - Parameter properties: The super properties to register.
  /// - Returns: An that registers super properties.
  public static func superProperties(_ properties: [String: Value?]) -> Self {
    .mixpanel { $0.registerSuperProperties(properties) }
  }
  
  /// An event that registers the specified dictionary of super properties once without overwriting
  /// properties that have been set, unless the existing value is equal to `defaultValue`.
  ///
  /// - Parameter properties: The super properties to register.
  /// - Returns: An that registers super properties.
  public static func superPropertiesOnce(
    _ properties: [String: Value?],
    defaultValue: Value? = nil
  ) -> Self {
    .mixpanel {
      $0.registerSuperPropertiesOnce(properties, defaultValue: defaultValue?.mixpanelType)
    }
  }
  
  /// An event that clears a super property with the specified name.
  ///
  /// - Parameter name: The name of the super property to remove.
  /// - Returns: An event that clears a super property.
  public static func clearSuperProperty(name: String) -> Self {
    .mixpanel { $0.unregisterSuperProperty(name) }
  }
  
  /// An event that clears all super properties.
  public static let clearAllSuperProperties = Self.mixpanel {
    $0.clearSuperProperties()
  }
}

// MARK: - Charge

extension AnalyticsEvent {
  /// An event to track money spent by the user for revenue analytics.
  ///
  /// - Parameters:
  ///   - amount: The amount of the charge.
  ///   - properties: Properties associated with this charge/
  /// - Returns: An event to track money spent by the user.
  public static func charge(amount: Double, properties: [String: Value?]? = nil) -> Self {
    .mixpanel { $0.people.trackCharge(amount: amount, properties: properties?.mixpanelProperties) }
  }
}

// MARK: - Groups

extension AnalyticsEvent {
  public typealias MixpanelGroupKey = String
  public typealias MixpanelGroupID = Value
  
  /// An event that sets the current user group.
  ///
  /// - Parameters:
  ///   - key: The property name associated with the group type (eg. "Company").
  ///   - id: The id of the group to associate the user with.
  /// - Returns: An event that sets the current user group.
  public static func setGroup(key: MixpanelGroupKey, id: MixpanelGroupID) -> Self {
    .setGroup(key: key, ids: [id])
  }
  
  /// An event that sets the current user group.
  ///
  /// - Parameters:
  ///   - key: The property name associated with the group type (eg. "Company").
  ///   - ids: The ids of the groups to associate the user with.
  /// - Returns: An event that sets the current user group.
  public static func setGroup(key: MixpanelGroupKey, ids: [MixpanelGroupID]) -> Self {
    .mixpanel { $0.setGroup(groupKey: key, groupIDs: ids.map(\.mixpanelType)) }
  }
  
  /// An event that sets the properties of a group.
  ///
  /// - Parameters:
  ///   - key: The property name associated with the group type (eg. "Company").
  ///   - id: The id of the group to associate the user with.
  ///   - properties: A dictionary of properties to set on the group.
  /// - Returns: An event that sets the properties of a group.
  public static func groupProperties(
    key: MixpanelGroupKey,
    id: MixpanelGroupID,
    _ properties: [String: Value?]
  ) -> Self {
    .mixpanel {
      $0.getGroup(groupKey: key, groupID: id.mixpanelType)
        .set(properties: properties.mixpanelProperties)
    }
  }
  
  /// An event that sets the properties of a group once without overwriting properties that have
  /// been set.
  ///
  /// - Parameters:
  ///   - key: The property name associated with the group type (eg. "Company").
  ///   - id: The id of the group to associate the user with.
  ///   - properties: A dictionary of properties to set on the group.
  /// - Returns: An event that sets the properties of a group once.
  public static func groupPropertiesOnce(
    key: MixpanelGroupKey,
    id: MixpanelGroupID,
    _ properties: [String: Value?]
  ) -> Self {
    .mixpanel {
      $0.getGroup(groupKey: key, groupID: id.mixpanelType)
        .setOnce(properties: properties.mixpanelProperties)
    }
  }
  
  /// An event to remove the user from a group.
  ///
  /// - Parameters:
  ///   - key: The group key.
  ///   - id: The id of the group.
  /// - Returns: An event to remove the user from a group.
  public static func removeGroup(key: MixpanelGroupKey, id: MixpanelGroupID) -> Self {
    .mixpanel { $0.removeGroup(groupKey: key, groupID: id.mixpanelType) }
  }
  
  /// An event that records an event with the associated properties and groups attached.
  ///
  /// - Parameters:
  ///   - name: The name of the event.
  ///   - properties: A dictionary of properties associated with the event.
  ///   - groups: A dictionary of `MixpanelGroupKey` to `MixpanelGroupID`.
  /// - Returns: An event that records an event with the associated properties and groups attached.
  public static func eventWithGroups(
    name: String,
    properties: [String: Value?] = [:],
    groups: [MixpanelGroupKey: MixpanelGroupID] = [:]
  ) -> Self {
    .mixpanel {
      $0.trackWithGroups(
        event: name,
        properties: properties.mixpanelProperties,
        groups: groups.mixpanelProperties
      )
    }
  }
}

// MARK: - Opt In

extension AnalyticsEvent {
  /// An event to opt the user into analytics tracking with a user id to send with every event,
  /// and a set of properties that is passed with the recorded opt-in event.
  ///
  /// - Parameters:
  ///   - userId: An id of which to associate the current user with.
  ///   - properties: A dictionary of properties to attach to the recorded opt-in event.
  /// - Returns: An event to the opt the user into analytics tracking.
  public static func optIn(
    userId: String? = nil,
    properties: [String: Value?]? = nil
  ) -> Self {
    .mixpanel {
      $0.optInTracking(distinctId: userId, properties: properties?.mixpanelProperties)
    }
  }
}

// MARK: - Reset

extension AnalyticsEvent {
  /// An event to clear all stored properties and user ids.
  ///
  /// This is particularly useful when the user logs out.
  public static let reset = Self.mixpanel { $0.reset() }
}

// MARK: - Helper

extension AnalyticsEvent {
  fileprivate static func mixpanel(_ record: @Sendable @escaping (MixpanelInstance) -> Void) -> Self {
    .custom(MixpanelEvent(record: record))
  }
}

private struct MixpanelEvent {
  let record: @Sendable (MixpanelInstance) -> Void
}

extension MixpanelEvent: Equatable {
  static func == (lhs: Self, rhs: Self) -> Bool {
    true
  }
}
