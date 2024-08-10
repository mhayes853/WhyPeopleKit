import Foundation

// MARK: - MIMEType

public struct MIMEType: RawRepresentable, Hashable, Sendable, Codable {
  public let rawValue: String
  
  public init(rawValue: String) {
    self.rawValue = rawValue
  }
}

// MARK: - ExpressibleByStringLiteral

extension MIMEType: ExpressibleByStringLiteral {
  public init(stringLiteral value: StringLiteralType) {
    self.init(rawValue: value)
  }
}

// MARK: - MIME Types

extension MIMEType {
  public static let zipArchive: Self = "application/zip"
  public static let text: Self = "text/plain"
  public static let png: Self = "image/png"
  public static let jpeg: Self = "image/jpeg"
  public static let html: Self = "text/html"
  public static let pdf: Self = "application/pdf"
  public static let xml: Self = "application/xml"
}
