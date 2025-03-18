#if canImport(WPGRDB)
  import WPGRDB
  import WPFoundation
  import Testing

  @Suite("StaticID+DatabaseValueConvertible tests")
  struct StaticIDDatabaseValueConvertibleTests {
    @Test("Convert from and to Database Value")
    func convert() {
      let baseId = StaticID()
      let id = StaticID.fromDatabaseValue(baseId.databaseValue)
      #expect(baseId == id)
    }

    @Test(
      "From Database Value",
      arguments: [
        (DatabaseValue.null, nil),
        (DatabaseValue(value: "a")!, nil),
        (DatabaseValue(value: 387)!, nil),
        (DatabaseValue(value: 1)!, StaticID())
      ]
    )
    func fromValue(value: DatabaseValue, id: StaticID?) {
      let newId = StaticID.fromDatabaseValue(value)
      #expect(newId == id)
    }
  }
#endif
