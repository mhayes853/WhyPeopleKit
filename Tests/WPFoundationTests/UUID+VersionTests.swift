import Testing
import WPFoundation

@Suite("UUID+Version tests")
struct UUIDVersionTests {
  @Test(
    "UUID Version",
    arguments: [
      (UUID(), 4),
      (UUID(uuidString: "1915C92E-B61E-7E3E-AFEA-2B5F3EA2DCF0")!, 7),
      (UUID(uuidString: "00000000-0000-0000-0000-000000000000")!, 0),
      (UUID(uuidString: "928ED28A-2B1C-6E3D-DF67-AA78BDE2892F")!, 6),
      (UUID(uuidString: "1B8A02DA-21A5-3563-A86C-312659D0D4AB")!, 3),
      (UUID(uuidString: "0FEE29D4-859D-2CDF-87D6-FF45FCD31FF5")!, 2),
      (UUID(uuidString: "46A69A73-7002-1AA5-8701-C338F147AF57")!, 1),
      (UUID(uuidString: "B84500C2-3C84-58D9-AFA7-15087BE628F7")!, 5)
    ]
  )
  func version(uuid: UUID, version: Int) {
    #expect(uuid.version == version)
  }
}
