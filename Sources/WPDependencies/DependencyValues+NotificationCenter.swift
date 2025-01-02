import Foundation

extension DependencyValues {
  /// A dependency for the current notification center.
  public var notificationCenter: NotificationCenter {
    get { self[NotificationCenterKey.self] }
    set { self[NotificationCenterKey.self] = newValue }
  }

  private enum NotificationCenterKey: DependencyKey {
    static var liveValue: NotificationCenter {
      .default
    }

    static var testValue: NotificationCenter {
      .default
    }
  }
}
