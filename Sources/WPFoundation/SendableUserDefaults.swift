import Foundation
import os

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

// NB: It shouldn't be possible for regex literals to be unsafe.
nonisolated(unsafe) private let swiftVariableName = /^[a-zA-Z_$][\w$]*$/

extension SendableUserDefaults {
  public struct Observation: Sendable {
    fileprivate let observer: Observer
  }
  
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
  
  public func removeObservation(_ observation: Observation) {
    self.removeObserver(observation.observer, forKeyPath: observation.observer.key)
  }
  
  private func debugValidKeyCheck(_ key: String) {
#if DEBUG
    if (try? swiftVariableName.wholeMatch(in: key)) == nil {
      runtimeWarn(
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
  public struct Values: Sendable {
    let key: String
    let options: NSKeyValueObservingOptions
    let userDefaults: SendableUserDefaults
    
    public func makeAsyncIterator() -> AsyncStream<Any?>.Iterator {
      AsyncStream { continuation in
        let observation = self.userDefaults.observeValue(
          forKey: self.key,
          options: self.options
        ) { continuation.yield($0) }
        continuation.onTermination = { @Sendable _ in
          self.userDefaults.removeObservation(observation)
        }
      }
      .makeAsyncIterator()
    }
  }
  
  public func values(
    forKey key: String,
    options: NSKeyValueObservingOptions = [.initial, .new]
  ) -> Values {
    Values(key: key, options: options, userDefaults: self)
  }
}
