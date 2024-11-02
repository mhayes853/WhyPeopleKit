#if !os(Linux)
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
    @available(iOS 16, macOS 13, tvOS 16, watchOS 9, *)
    func infersMIMEType(url: URL, mimeType: MIMEType?) async throws {
      #expect(EmailComposerAttachment(url: url, filename: "test")?.mimeType == mimeType)
    }
  }
#endif
