import Testing
import WPFoundation

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
  func fromURL(url: URL, type: MIMEType?) {
    #expect(MIMEType(of: url) == type)
  }
}
