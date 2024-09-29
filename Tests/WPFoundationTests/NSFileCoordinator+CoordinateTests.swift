import Testing
import WPFoundation

@Suite("NSFileCoordinator+Coordinate tests")
struct NSFileCoordinatorCoordinateTests {
  @Test("Reading Throws Error")
  func readingThrows() throws {
    let coordinator = NSFileCoordinator()
    #expect(throws: SomeError.self) {
      try coordinator.coordinate(readingItemAt: testURL) { _ in
        throw SomeError()
      }
    }
  }

  @Test("Reading Returns")
  func readingReturns() throws {
    let coordinator = NSFileCoordinator()
    let value = try coordinator.coordinate(readingItemAt: testURL) { _ in
      1
    }
    #expect(value == 1)
  }

  @Test("Writing Throws Error")
  func writingThrows() throws {
    let coordinator = NSFileCoordinator()
    #expect(throws: SomeError.self) {
      try coordinator.coordinate(writingItemAt: testURL) { _ in
        throw SomeError()
      }
    }
  }

  @Test("Writing Returns")
  func writingReturns() throws {
    let coordinator = NSFileCoordinator()
    let value = try coordinator.coordinate(writingItemAt: testURL) { _ in
      1
    }
    #expect(value == 1)
  }
}

private let testURL = URL.documentsDirectory.appending(path: "test.json")

private struct SomeError: Error {}
