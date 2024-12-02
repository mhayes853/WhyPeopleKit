import Testing
import WPFoundation

@Suite("IPV4Address tests")
struct IPV4AddressTests {
  @Test("Local Private Address")
  func localPrivateIP() throws {
    guard let address = IPV4Address.localPrivate else { return }
    let prefixes = ["10.0.0", "192.168", "172.16"]
    #expect(prefixes.contains { address.description.starts(with: $0) })
  }
}
