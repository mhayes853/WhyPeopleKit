#if !os(Linux)
  import Testing
  import WPFoundation

  @Suite("NSFileCoordinator+Coordinate tests")
  struct NSFileCoordinatorCoordinateTests {
    @Test("Reading Throws Error")
    @available(iOS 16, macOS 13, tvOS 16, watchOS 9, *)
    func readingThrows() throws {
      let coordinator = NSFileCoordinator()
      #expect(throws: SomeError.self) {
        try coordinator.coordinate(readingItemAt: testURL) { _ in
          throw SomeError()
        }
      }
    }

    @Test("Reading Returns")
    @available(iOS 16, macOS 13, tvOS 16, watchOS 9, *)
    func readingReturns() throws {
      let coordinator = NSFileCoordinator()
      let value = try coordinator.coordinate(readingItemAt: testURL) { _ in
        1
      }
      #expect(value == 1)
    }

    @Test("Writing Throws Error")
    @available(iOS 16, macOS 13, tvOS 16, watchOS 9, *)
    func writingThrows() throws {
      let coordinator = NSFileCoordinator()
      #expect(throws: SomeError.self) {
        try coordinator.coordinate(writingItemAt: testURL) { _ in
          throw SomeError()
        }
      }
    }

    @Test("Writing Returns")
    @available(iOS 16, macOS 13, tvOS 16, watchOS 9, *)
    func writingReturns() throws {
      let coordinator = NSFileCoordinator()
      let value = try coordinator.coordinate(writingItemAt: testURL) { _ in
        1
      }
      #expect(value == 1)
    }
  }

  @available(iOS 16, macOS 13, tvOS 16, watchOS 9, *)
  private var testURL: URL {
    URL.documentsDirectory.appending(path: "test.json")
  }

  private struct SomeError: Error {}
#endif
