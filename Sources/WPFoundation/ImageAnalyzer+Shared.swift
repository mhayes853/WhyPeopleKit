#if canImport(VisionKit)
  import VisionKit

  @available(iOS 16, macOS 13, *)
  extension ImageAnalyzer {
    /// A shared `ImageAnalyzer` instance that can be used throughout your entire app.
    public static let shared = ImageAnalyzer()
  }
#endif
