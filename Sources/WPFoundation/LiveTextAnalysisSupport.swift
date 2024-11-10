#if canImport(SwiftUI) && canImport(VisionKit)
  import SwiftUI
  import VisionKit

  /// A data type containing information on the support of live text analysis using VisionKit.
  @available(iOS 16, macOS 13, *)
  public struct LiveTextAnalysisSupport: Hashable, Sendable {
    /// Whether or not the device supports image analysis.
    public var isImageAnalysisSupported: Bool

    /// The identifiers for the languages that the image analyzer recognizes.
    public var supportedTextRecognitionLanguages: [String]

    /// Creates a live text analysis support instance.
    ///
    /// - Parameters:
    ///   - isImageAnalysisSupported: Whether or not the device supports image analysis.
    ///   - supportedTextRecognitionLanguages: The identifiers for the languages that the image analyzer recognizes.
    public init(
      isImageAnalysisSupported: Bool = ImageAnalyzer.isSupported,
      supportedTextRecognitionLanguages: [String] = ImageAnalyzer.supportedTextRecognitionLanguages
    ) {
      self.isImageAnalysisSupported = isImageAnalysisSupported
      self.supportedTextRecognitionLanguages = supportedTextRecognitionLanguages
    }
  }

  @available(iOS 16, macOS 13, *)
  extension EnvironmentValues {
    /// The current ``LiveTextAnalysisSupport`` in this environment.
    @Entry public var liveTextAnalysisSupport = LiveTextAnalysisSupport()
  }
#endif
