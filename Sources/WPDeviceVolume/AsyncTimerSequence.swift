//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Async Algorithms open source project
//
// Copyright (c) 2022 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

@available(iOS 16, macOS 13, tvOS 16, watchOS 8, *)
public struct _AsyncTimerSequence<C: Clock>: AsyncSequence, Sendable {
  public typealias Element = Void

  public struct Iterator: AsyncIteratorProtocol, Sendable {
    var clock: C?
    let interval: C.Instant.Duration
    let tolerance: C.Instant.Duration?
    var last: C.Instant?

    init(interval: C.Instant.Duration, tolerance: C.Instant.Duration?, clock: C) {
      self.clock = clock
      self.interval = interval
      self.tolerance = tolerance
    }

    func nextDeadline(_ clock: C) -> C.Instant {
      let now = clock.now
      let last = self.last ?? now
      let next = last.advanced(by: interval)
      if next < now {
        return last.advanced(
          by: interval * Int(((next.duration(to: now)) / interval).rounded(.up))
        )
      } else {
        return next
      }
    }

    public mutating func next() async -> Element? {
      guard let clock = clock else {
        return nil
      }
      let next = nextDeadline(clock)
      do {
        try await clock.sleep(until: next, tolerance: tolerance)
      } catch {
        self.clock = nil
        return nil
      }
      last = next
      return ()
    }
  }

  let clock: C
  let interval: C.Instant.Duration
  let tolerance: C.Instant.Duration?

  init(interval: C.Instant.Duration, tolerance: C.Instant.Duration? = nil, clock: C) {
    self.clock = clock
    self.interval = interval
    self.tolerance = tolerance
  }

  public func makeAsyncIterator() -> Iterator {
    Iterator(interval: interval, tolerance: tolerance, clock: clock)
  }
}
