#if canImport(MessageUI)
  import Foundation
  import Testing
  import WPSwiftNavigation
  import MessageUI

  @Suite("EmailComposer tests")
  struct EmailComposerTests {
    @MainActor
    @Suite("MFMailComposeViewController+SetState tests")
    struct MFMailComposeViewControllerSetStateTests {
      private let url = URL.documentsDirectory.appending(path: "hello.txt")
      init() {
        try? FileManager.default.removeItem(at: self.url)
      }

      @Test("Does not throw when attachments are valid")
      func doesNotThrow() async throws {
        try Data("hello".utf8).write(to: self.url)

        let state = EmailComposerState(
          attachments: [
            EmailComposerAttachment(
              url: url,
              mimeType: .text,
              filename: "hello.txt"
            ),
            EmailComposerAttachment(
              data: Data("world".utf8),
              mimeType: .text,
              filename: "world.txt"
            )
          ]
        )
        #expect(throws: Never.self) {
          _ = try MFMailComposeViewController(state: state)
        }
      }

      @Test("Throws when attachments are invalid")
      func `throws`() async throws {
        let state = EmailComposerState(
          attachments: [
            EmailComposerAttachment(
              url: self.url,
              mimeType: .text,
              filename: "hello.txt"
            ),
            EmailComposerAttachment(
              data: Data("world".utf8),
              mimeType: .text,
              filename: "world.txt"
            )
          ]
        )
        #expect(throws: Error.self) {
          _ = try MFMailComposeViewController(state: state)
        }
      }
    }
  }
#endif
