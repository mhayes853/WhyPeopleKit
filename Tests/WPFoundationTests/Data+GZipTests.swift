#if canImport(zlib)
  import Testing
  import WPFoundation
  import CustomDump

  @Suite("Data+GZip tests")
  struct DataGZipTests {
    @Test("gzipped")
    func gzipped() throws {
      let data = Data("I am the freaking data to compress!".utf8)
      let compressedData = try data.gzipped().base64EncodedString()
      expectNoDifference(
        compressedData,
        "eJzzVEjMVSjJSFVIK0pNzM7MS1dISSxJVCjJV0jOzy0oSi0uVgQA2MMMag=="
      )
    }
  }
#endif
