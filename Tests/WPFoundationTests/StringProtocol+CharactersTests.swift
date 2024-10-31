import Testing
import WPFoundation

@Suite("StringProtocol+Characters tests")
struct StringProtocolCharactersTests {
  @Test(
    "First Character Capitalization",
    arguments: [
      ("", ""),
      ("hello", "Hello"),
      ("   ", "   "),
      ("1234", "1234"),
      ("1a2b3c", "1a2b3c"),
      ("this is a test", "This is a test"),
      ("✅ this is an emoji", "✅ this is an emoji"),
      ("🤔➰🙄😛", "🤔➰🙄😛")
    ]
  )
  func capitalizeFirst(string: String, expected: String) {
    #expect(string.firstCharacterCapitalized == expected)
  }

  @Test(
    "First Character Lowercased",
    arguments: [
      ("", ""),
      ("Hello", "hello"),
      ("   ", "   "),
      ("1234", "1234"),
      ("1a2b3c", "1a2b3c"),
      ("This is a test", "this is a test"),
      ("✅ this is an emoji", "✅ this is an emoji"),
      ("🤔➰🙄😛", "🤔➰🙄😛")
    ]
  )
  func lowercaseFirst(string: String, expected: String) {
    #expect(string.firstCharacterLowercased == expected)
  }

  @Test(
    "Character Before Index, Non Empty Returns Character Before or Nil",
    arguments: [
      ("hello", "h", nil),
      ("1234", "2", "1"),
      ("1a2b3c", "3", "b"),
      ("🤔➰🙄😛", "🙄", "➰")
    ]
  )
  func characterBeforeNonEmpty(string: String, char: Character, before: Character?) throws {
    let index = try #require(string.firstIndex { $0 == char })
    #expect(string.character(before: index) == before)
  }

  @Test(
    "Character After Index, Non Empty Returns Character Before or Nil",
    arguments: [
      ("hello", "o", nil),
      ("1234", "2", "3"),
      ("1a2b3c", "3", "c"),
      ("🤔➰🙄😛", "🙄", "😛")
    ]
  )
  func characterAfterNonEmpty(string: String, char: Character, before: Character?) throws {
    let index = try #require(string.firstIndex { $0 == char })
    #expect(string.character(after: index) == before)
  }
}
