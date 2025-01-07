import Testing
import WPFoundation

@Suite("Lock tests")
struct LockTests {
  @Test("Concurrent Increment")
  func concurrentIncrement() async {
    let counter = Counter()
    await withTaskGroup(of: Void.self) { group in
      for _ in 0..<100 {
        group.addTask { counter.increment() }
      }
    }
    #expect(counter.count == 100)
  }

  @Test("Recursive Concurrent Increment")
  func recursiveConcurrentIncrement() async {
    let counter = RecursiveCounter()
    await withTaskGroup(of: Void.self) { group in
      for _ in 0..<100 {
        group.addTask { counter.incrementTwice() }
      }
    }
    #expect(counter.count == 200)
  }
}

private final class RecursiveCounter: Sendable {
  private let _count = RecursiveLock(0)

  var count: Int {
    self._count.withLock { $0 }
  }

  func incrementTwice() {
    self._count.withLock {
      $0 += 1
      self._count.withLock {
        $0 += 1
      }
    }
  }
}

private final class Counter: Sendable {
  private let _count = Lock(0)

  var count: Int {
    self._count.withLock { $0 }
  }

  func increment() {
    self._count.withLock { $0 += 1 }
  }
}
