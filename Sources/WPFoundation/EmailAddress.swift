import Foundation
import RegexBuilder

// MARK: - EmailAddress

private nonisolated(unsafe) let emailRegex = Regex {
  /^/
  NegativeLookahead {
    "."
  }
  NegativeLookahead {
    Regex {
      ZeroOrMore {
        /./
      }
      ".."
    }
  }
  Capture {
    ZeroOrMore {
      CharacterClass(
        .anyOf("_'+-."),
        ("A"..."Z"),
        ("a"..."z"),
        ("0"..."9")
      )
    }
  }
  CharacterClass(
    .anyOf("_+-"),
    ("A"..."Z"),
    ("a"..."z"),
    ("0"..."9")
  )
  "@"
  OneOrMore {
    Capture {
      Regex {
        CharacterClass(
          ("A"..."Z"),
          ("a"..."z"),
          ("0"..."9")
        )
        ZeroOrMore {
          CharacterClass(
            .anyOf("-"),
            ("A"..."Z"),
            ("a"..."z"),
            ("0"..."9")
          )
        }
        "."
      }
    }
  }
  Repeat(2...) {
    CharacterClass(
      ("A"..."Z"),
      ("a"..."z")
    )
  }
  /$/
}

/// A data type representing a valid email address.
public struct EmailAddress: Hashable, Sendable, Codable {
  public let rawValue: String
  
  /// Attempts to create an email address by validating the specifed string.
  ///
  /// - Parameter email: An email string.
  public init?(_ email: String) {
    guard email.wholeMatch(of: emailRegex) != nil else { return nil }
    self.rawValue = email
  }
}

// MARK: - RawRepresentable

extension EmailAddress: RawRepresentable {
  public init?(rawValue: String) {
    self.init(rawValue)
  }
}

// MARK: - No Validation Init

extension EmailAddress {
  /// Inittializes an email address with the specified email string skipping validation.
  ///
  /// - Parameter email: An email string.
  public init(unsafeNoValidation email: String) {
    self.rawValue = email
  }
}