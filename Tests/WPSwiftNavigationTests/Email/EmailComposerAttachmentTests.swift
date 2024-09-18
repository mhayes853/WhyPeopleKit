import Testing
import WPFoundation
import WPSwiftNavigation

@Suite("EmailComposerAttachment tests")
struct EmailComposerAttachmentTests {
  @Test(
    "Infers MIMEType from URL",
    arguments: [
      (URL.documentsDirectory, nil),
      (URL.documentsDirectory.appending(path: "test.json"), MIMEType.json),
      (URL(string: "https://www.example.com")!, nil)
    ]
  )
  func infersMIMEType(url: URL, mimeType: MIMEType?) async throws {
    #expect(EmailComposerAttachment(url: url, filename: "test")?.mimeType == mimeType)
  }
}
