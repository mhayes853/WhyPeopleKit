import Foundation

// MARK: - EmailComposerAttachment

public struct EmailComposerAttachment: Hashable, Sendable {
  public var contents: Contents
  public var mimeType: MIMEType
  public var filename: String
  
  public init(data: Data, mimeType: MIMEType, filename: String) {
    self.contents = .data(data)
    self.mimeType = mimeType
    self.filename = filename
  }
  
  public init(url: URL, mimeType: MIMEType, filename: String) {
    self.contents = .url(url)
    self.mimeType = mimeType
    self.filename = filename
  }
}

// MARK: - Contents

extension EmailComposerAttachment {
  public enum Contents: Hashable, Sendable {
    case data(Data)
    case url(URL)
  }
}

extension EmailComposerAttachment.Contents {
  public func data() throws -> Data {
    switch self {
    case let .data(data): data
    case let .url(url): try Data(contentsOf: url)
    }
  }
}
