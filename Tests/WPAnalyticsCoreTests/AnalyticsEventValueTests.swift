import CustomDump
import Foundation
import Testing
import WPAnalyticsCore

@Suite("AnalyticsEventValue tests")
struct AnalyticsEventValueTests {
  @Test("Encodes Int Value To Int")
  func encodesIntValueToInt() throws {
    let event = AnalyticsEvent.Value.integer(10)
    let data = try JSONEncoder().encode(event)
    expectNoDifference(try JSONDecoder().decode(Int.self, from: data), 10)
  }

  @Test("Encodes Unsigned Int Value To Int")
  func encodesUnsignedIntValueToInt() throws {
    let event = AnalyticsEvent.Value.unsignedInteger(UInt(10))
    let data = try JSONEncoder().encode(event)
    expectNoDifference(try JSONDecoder().decode(Int.self, from: data), 10)
  }

  @Test("Encodes Double Value To Double")
  func encodesDoubleValueToDouble() throws {
    let event = AnalyticsEvent.Value.double(10.5)
    let data = try JSONEncoder().encode(event)
    expectNoDifference(try JSONDecoder().decode(Double.self, from: data), 10.5)
  }

  @Test("Encodes Float Value To Float")
  func encodesFloatValueToDouble() throws {
    let event = AnalyticsEvent.Value.float(Float(10.5))
    let data = try JSONEncoder().encode(event)
    expectNoDifference(try JSONDecoder().decode(Float.self, from: data), 10.5)
  }

  @Test("Encodes String Value To String")
  func encodesStringValueToString() throws {
    let event = AnalyticsEvent.Value.string("test")
    let data = try JSONEncoder().encode(event)
    expectNoDifference(try JSONDecoder().decode(String.self, from: data), "test")
  }

  @Test("Encodes Bool Value To Bool")
  func encodesBoolValueToBool() throws {
    let event = AnalyticsEvent.Value.boolean(true)
    let data = try JSONEncoder().encode(event)
    expectNoDifference(try JSONDecoder().decode(Bool.self, from: data), true)
  }

  @Test("Encodes Date Value To Date")
  func encodesDateValueToDate() throws {
    let date = Date()
    let event = AnalyticsEvent.Value.date(date)
    let data = try JSONEncoder().encode(event)
    expectNoDifference(try JSONDecoder().decode(Date.self, from: data), date)
  }

  @Test("Encodes URL Value To URL")
  func encodesURLValueToURL() throws {
    let url = URL(string: "https://example.com")!
    let event = AnalyticsEvent.Value.url(url)
    let data = try JSONEncoder().encode(event)
    expectNoDifference(try JSONDecoder().decode(URL.self, from: data), url)
  }

  @Test("Encodes Array Value To Array")
  func encodesArrayValueToArray() throws {
    let event = AnalyticsEvent.Value.array([1, "blob", nil])
    let data = try JSONEncoder().encode(event)
    expectNoDifference(String(decoding: data, as: UTF8.self), "[1,\"blob\",null]")
  }

  @Test("Encodes Dictionary Value To Dictionary")
  func encodesDictionaryValueToDictionary() throws {
    let event = AnalyticsEvent.Value.dict(["key": "value"])
    let data = try JSONEncoder().encode(event)
    expectNoDifference(String(decoding: data, as: UTF8.self), "{\"key\":\"value\"}")
  }

  @Test("Encode And Decode Dictionary")
  func encodeAndDecodeDictionary() throws {
    let event = AnalyticsEvent.Value.dict([
      "key": "value", "key2": [1, [], 10.1, "blob"]
    ])
    let data = try JSONEncoder().encode(event)
    expectNoDifference(try JSONDecoder().decode(AnalyticsEvent.Value.self, from: data), event)
  }
}
