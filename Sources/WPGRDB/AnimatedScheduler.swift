#if canImport(GRDB)
  import GRDB
  import SwiftUI

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
    public static func animation(_ animation: Animation?) -> Self {
      AnimatedScheduler(animation: animation)
    }
  }
#endif
