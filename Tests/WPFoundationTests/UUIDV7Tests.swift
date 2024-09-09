import WPFoundation
import Testing

@Suite("UUIDV7 tests")
struct UUIDV7Tests {
  @Test(
    "From UUID Invalid",
    arguments: [
      UUID(),
      UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
      UUID(uuidString: "A123209E-52CB-4FE4-932F-DB30BAB742CB")!,
      UUID(uuidString: "1915C92E-B61E-4E3E-AFEA-2B5F3EA2DCF0")!,
      UUID(uuidString: "A123209E-52CB-7FE4-C32F-DB30BAB742CB")!,
      UUID(uuid: (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16))
    ]
  )
  func fromUUIDInvalid(uuid: UUID) async throws {
    #expect(UUIDV7(uuid) == nil)
  }
  
  @Test(
    "From UUID Valid",
    arguments: [
      UUID(uuidString: "1915C92E-B61E-7E3E-AFEA-2B5F3EA2DCF0")!,
      UUID(uuidString: "A123209E-52CB-7FE4-932F-DB30BAB742CB")!,
      UUID(uuidString: "00000000-0000-7000-A000-000000000000")!,
      UUID(uuid: (25, 21, 201, 46, 182, 30, 126, 62, 175, 234, 43, 95, 62, 162, 220, 240)),
      UUID(uuidString: "0191D85B-8C41-7445-9473-A0B0C24B58A4")!
    ]
  )
  func fromUUIDValid(uuid: UUID) async throws {
    #expect(UUIDV7(uuid)?.rawValue == uuid)
  }
  
  @Test(
    "From UUID String Invalid",
    arguments: [
      UUID().uuidString,
      "00000000-0000-0000-0000-000000000000",
      "A123209E-52CB-7FE4-C32F-DB30BAB742CB",
      "A123209E-52CB-4FE4-932F-DB30BAB742CB",
      "1915C92E-B61E-4E3E-AFEA-2B5F3EA2DCF0"
    ]
  )
  func fromUUIDStringInvalid(uuid: String) async throws {
    #expect(UUIDV7(uuidString: uuid) == nil)
  }
  
  @Test(
    "From UUID String Valid",
    arguments: [
      "1915C92E-B61E-7E3E-AFEA-2B5F3EA2DCF0",
      "A123209E-52CB-7FE4-932F-DB30BAB742CB",
      "00000000-0000-7000-A000-000000000000",
      "0191D85B-8C41-7445-9473-A0B0C24B58A4"
    ]
  )
  func fromUUIDStringValid(uuid: String) async throws {
    #expect(UUIDV7(uuidString: uuid)?.uuidString == uuid)
  }
  
  @Test(
    "From uuid_t Invalid",
    arguments: [
      UUID(uuid: UUID().uuid),
      UUID(uuid: (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16))
    ]
  )
  func fromUUIDTInvalid(uuid: UUID) async throws {
    #expect(UUIDV7(uuid: uuid.uuid) == nil)
  }
  
  @Test(
    "From uuid_t Valid",
    arguments: [
      UUID(uuid: (25, 21, 201, 46, 182, 30, 126, 62, 175, 234, 43, 95, 62, 162, 220, 240)),
      UUID(uuid: (161, 35, 32, 158, 82, 203, 127, 228, 147, 47, 219, 48, 186, 183, 66, 203))
    ]
  )
  func fromUUIDTValid(uuid: UUID) async throws {
    let uuid2 = try #require(UUIDV7(uuid: uuid.uuid)?.uuid)
    #expect(UUID(uuid: uuid2) == uuid)
  }
}
