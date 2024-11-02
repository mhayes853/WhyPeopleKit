#if !os(Linux)
  import Testing
  import WPFoundation

  @Suite("IPV4Address tests")
  struct IPV4AddressTests {
    @Test("Local Private Address")
    func localPrivateIP() throws {
      let address = try #require(IPV4Address.localPrivate)
      #expect(address.description.starts(with: "10.0.0"))
    }
  }
#endif
