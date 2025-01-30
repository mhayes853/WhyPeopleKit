#if canImport(GRDB)
  import GRDB
  import SwiftUI

  /// A `ValueObservationScheduler` that plays an animation on the main queue.
  public struct AnimatedScheduler: ValueObservationScheduler {
    let animation: Animation?

    public func immediateInitialValue() -> Bool { true }

    public func schedule(_ action: @escaping @Sendable () -> Void) {
      if let animation {
        DispatchQueue.main.async {
          withAnimation(animation) {
            action()
          }
        }
      } else {
        DispatchQueue.main.async(execute: action)
      }
    }
  }

  extension ValueObservationScheduler where Self == AnimatedScheduler {
    /// A `ValueObservationScheduler` that plays an animation on the main queue.
    ///
    /// - Parameter animation: The animation to play.
    /// - Returns: A value observation scheduler/
    public static func animation(_ animation: Animation?) -> Self {
      AnimatedScheduler(animation: animation)
    }
  }
#endif
