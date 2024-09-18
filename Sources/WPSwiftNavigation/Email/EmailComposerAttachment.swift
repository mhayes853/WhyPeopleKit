import WPFoundation

// MARK: - EmailComposerAttachment

/// An attachment to use for emails.
///
/// An attachment can either be created with `Data`, or with a filesystem `URL`. In the latter case,
/// the data will be loaded before presenting the mail composer, and a loading error will result
/// in an error status being returned from the mail composer.
public struct EmailComposerAttachment: Hashable, Sendable {
  public var contents: Contents
  public var mimeType: MIMEType
  public var filename: String

  /// Creates an attachment with data.
  ///
  /// - Parameters:
  ///   - data: The `Data` contents of the attachment.
  ///   - mimeType: The ``MIMEType`` of the attachment.
  ///   - filename: The filename to use for the attachment in the email composer.
  public init(data: Data, mimeType: MIMEType, filename: String) {
    self.contents = .data(data)
    self.mimeType = mimeType
    self.filename = filename
  }

  /// Creates an attachment with a filesystem `URL`.
  ///
  /// The data from `url` will be loaded just before presenting the email composer, and an error
  /// result will be returned from the composer if the data cannot be loaded from `url`.
  ///
  /// - Parameters:
  ///   - url: A filesystem `url`.
  ///   - mimeType: The ``MIMEType`` of the attachment.
  ///   - filename: The filename to use for the attachment in the email composer.
  public init(url: URL, mimeType: MIMEType, filename: String) {
    self.contents = .url(url)
    self.mimeType = mimeType
    self.filename = filename
  }

  /// Attempts to create an attachment with a filesystem `URL` by recognizing its `MIMEType`.
  ///
  /// The data from `url` will be loaded just before presenting the email composer, and an error
  /// result will be returned from the composer if the data cannot be loaded from `url`.
  ///
  /// - Parameters:
  ///   - url: A filesystem `url`.
  ///   - filename: The filename to use for the attachment in the email composer.
  public init?(url: URL, filename: String) {
    guard let mimeType = MIMEType(of: url) else { return nil }
    self.contents = .url(url)
    self.mimeType = mimeType
    self.filename = filename
  }
}

// MARK: - Contents

extension EmailComposerAttachment {
  /// The contents of an ``EmailComposerAttachment``.
  ///
  /// The content can either be `Data`, or with a filesystem `URL`. In the latter case, the data
  /// will be loaded before presenting the mail composer, and a loading error will result in an
  /// error status being returned from the mail composer.
  public enum Contents: Hashable, Sendable {
    case data(Data)
    case url(URL)
  }
}

extension EmailComposerAttachment.Contents {
  /// Attempts to load the data from these contents.
  ///
  /// - Returns: The `Data` of these contents.
  public func data() throws -> Data {
    switch self {
    case let .data(data): data
    case let .url(url): try Data(contentsOf: url)
    }
  }
}
