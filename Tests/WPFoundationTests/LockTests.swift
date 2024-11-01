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
