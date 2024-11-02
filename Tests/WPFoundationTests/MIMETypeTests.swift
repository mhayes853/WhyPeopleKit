import Testing
import WPFoundation

#if !os(Linux)
  @Suite("MIMEType tests")
  struct MIMETypeTests {
    @Test(
      "From URL",
      arguments: [
        (URL.documentsDirectory.appending(path: "test.txt"), MIMEType.text),
        (URL.documentsDirectory, nil),
        (URL(string: "https://www.example.com")!, nil),
        (URL.documentsDirectory.appending(path: "user.json"), MIMEType.json),
        (
          URL.documentsDirectory.appending(component: "test", directoryHint: .notDirectory),
          MIMEType.octetStream
        )
      ]
    )
    @available(iOS 16, macOS 13, tvOS 16, watchOS 9, *)
    func fromURL(url: URL, type: MIMEType?) {
      #expect(MIMEType(of: url) == type)
    }
  }
#endif
