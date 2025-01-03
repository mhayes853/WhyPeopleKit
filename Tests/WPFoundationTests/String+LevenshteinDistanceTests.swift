import IssueReporting
import Testing
import WPFoundation

@Suite("String+LevenshteinDistance tests")
struct StringLevenshteinDistanceTests {
  @Test(
    "Levenshtein Distance",
    arguments: [
      ("", "", 0),
      ("hello", "hello", 0),
      ("kitten", "sitting", 3),
      ("blob", "", 4),
      ("", "blob", 4),
      ("hello", "help", 2),
      ("foo", "bar", 3),
      ("abcdef", "ghijkl", 6),
      ("abcdef", "ghi", 6),
      ("book", "back", 2),
      (
        "a quick brown fox jumps over the lazy dog",
        "the people of chaosflame are stronger then those in the shinobi village",
        55
      ),
      (
        "Blob is the dark lord of the world.",
        "Z is the nicest guy in the world.",
        16
      ),
      (
        "Previously, I wrote about the Dark Lord Blob.",
        "Blob is an interesting character, though don't ask why he's named blob...",
        53
      ),
      ("These are some emojis 🔴📱⏳.", "These are some emojis 🔴🛠️⏳.", 1)
    ]
  )
  func distance(a: String, b: String, dist: Int) {
    #expect(a.levenshteinDistance(from: b) == dist)
  }

  @Test("Performance")
  func performance() {
    let a = "Previously, I wrote about the Dark Lord Blob."
    let b = "Blob is an interesting character, though don't ask why he's named blob..."
    let time = ContinuousClock()
      .measure {
        for _ in 0..<1000 {
          _ = a.levenshteinDistance(from: b)
        }
      }
    withExpectedIssue {
      reportIssue("Computed 1000 Levenshteins in \(time).")
    }
  }
}
