import Foundation
private import IssueReporting

// MARK: - SendableUserDefaults

/// A `Sendable` conforming `UserDefaults` subclass.
///
/// `UserDefaults` is thread-safe, but isn't marked as `Sendable` because it can be subclassed, therefore
/// since this subclass is final, we can safely mark it as `@unchecked Sendable`.
public final class SendableUserDefaults: UserDefaults, @unchecked Sendable {
  private static let _standard = SendableUserDefaults()
  public override class var standard: SendableUserDefaults {
    Self._standard
  }
}

// MARK: - Observation

#if !os(Linux)
  extension SendableUserDefaults {
    /// A token of observation from a ``SendableUserDefaults`` instance.
    ///
    /// You do not create instances of this type, rather you call ``observeValue(forKey:options:_:)``
    /// to observe the value for specified key in the current defaults database. The returned
    /// instance can be passed to ``removeObservation(_:)`` to cancel the observation.
    public struct Observation: Sendable {
      fileprivate let observer: Observer
    }

    /// Observes a value for a specified key in an update closure.
    ///
    /// The key must be formatted like a swift variable name. Otherwise, value updates will not be
    /// emitted after the update for the initial value. A runtime warning will be issued if the key
    /// is not formatted properly.
    ///
    /// ```swift
    /// // 🔴
    /// let bad = SendableUserDefaults.standard.values(forKey: "hello.world")
    /// // ✅
    /// let good = SendableUserDefaults.standard.values(forKey: "helloWorld")
    /// ```
    ///
    /// - Parameters:
    ///   - key: A key in the current user‘s defaults database.
    ///   - options: A combination of the `NSKeyValueObservingOptions` values that specifies what is included in observation notifications. For possible values, see `NSKeyValueObservingOptions`.
    ///   - onUpdate: A closure that runs with the most recently emitted value.
    /// - Returns: An ``Observation`` that can be passed to ``removeObservation(_:)`` to cancel this observation and not receive future updates.
    public func observeValue(
      forKey key: String,
      options: NSKeyValueObservingOptions = [.initial, .new],
      _ onUpdate: @Sendable @escaping (Any?) -> Void
    ) -> Observation {
      self.debugValidKeyCheck(key)
      let observer = Observer(key: key, onUpdate: onUpdate)
      self.addObserver(observer, forKeyPath: key, options: options, context: nil)
      return Observation(observer: observer)
    }

    /// Cancels an observation from ``observeValue(forKey:options:_:)``.
    ///
    /// - Parameter observation: An ``Observation``.
    public func removeObservation(_ observation: Observation) {
      self.removeObserver(observation.observer, forKeyPath: observation.observer.key)
    }

    fileprivate final class Observer: NSObject, Sendable {
      let key: String
      private let onUpdate: @Sendable (Any?) -> Void

      init(key: String, onUpdate: @Sendable @escaping (Any?) -> Void) {
        self.key = key
        self.onUpdate = onUpdate
        super.init()
      }

      override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey: Any]?,
        context: UnsafeMutableRawPointer?
      ) {
        guard let userDefaults = object as? SendableUserDefaults else { return }
        self.onUpdate(userDefaults.object(forKey: self.key))
      }
    }
  }

  // MARK: - AsyncSequence

  extension SendableUserDefaults {
    /// An asynchronous sequence of updates to the value for a specified key.
    public struct Values: AsyncSequence, Sendable {
      let key: String
      let options: NSKeyValueObservingOptions
      let userDefaults: SendableUserDefaults

      public func makeAsyncIterator() -> AsyncStream<Any?>.Iterator {
        AsyncStream { continuation in
          let observation = self.userDefaults.observeValue(
            forKey: self.key,
            options: self.options
          ) { value in
            // NB: Safe - Stored UserDefaults Values are plist values, which are Sendable.
            nonisolated(unsafe) let value = value
            continuation.yield(value)
          }
          continuation.onTermination = { @Sendable _ in
            self.userDefaults.removeObservation(observation)
          }
        }
        .makeAsyncIterator()
      }
    }

    /// An asynchronous sequence of updates to the value for a specified key.
    ///
    /// The key must be formatted like a swift variable name. Otherwise, value updates will not be
    /// emitted after the update for the initial value. A runtime warning will be issued if the key
    /// is not formatted properly.
    ///
    /// ```swift
    /// // 🔴
    /// let bad = SendableUserDefaults.standard.values(forKey: "hello.world")
    /// // ✅
    /// let good = SendableUserDefaults.standard.values(forKey: "helloWorld")
    /// ```
    ///
    /// - Parameters:
    ///   - key: A key in the current user‘s defaults database.
    ///   - options: A combination of the `NSKeyValueObservingOptions` values that specifies what is included in observation notifications. For possible values, see `NSKeyValueObservingOptions`.
    /// - Returns: An asynchronous sequence emitting updates for the value at a specified key.
    public func values(
      forKey key: String,
      options: NSKeyValueObservingOptions = [.initial, .new]
    ) -> Values {
      self.debugValidKeyCheck(key)
      return Values(key: key, options: options, userDefaults: self)
    }
  }

  // MARK: - Valid Key Check

  #if DEBUG
    // NB: It shouldn't be possible for regex literals to be non-thread-safe.
    private let swiftVariableName = try! NSRegularExpression(
      pattern: "^[a-zA-Z_$][\\w$]*$"
    )
  #endif

  extension SendableUserDefaults {
    private func debugValidKeyCheck(_ key: String) {
      #if DEBUG
        if swiftVariableName.firstMatch(in: key, range: NSRange(0..<key.count)) == nil {
          reportIssue(
            """
            An invalid key format was detected for SendableUserDefaults value observation:

              - Key: \(key)

            Key names which do not use the same format as swift variable names will not receive any \
            KVO updates.
            """
          )
        }
      #endif
    }
  }
#endif
