import Dependencies

#if os(iOS) || os(visionOS)
  import UIKit

  extension DependencyValues {
    /// The current `UIPasteboard` that features should use when implementing copy-paste actions.
    ///
    /// By default, `UIPasteboard.general` is supplied. In test contexts you can provide an instance
    /// using `UIPasteboard.withUniqueName()` inside a `withDependencies` update block.
    ///
    /// ```swift
    /// // Provision model with overridden dependencies
    /// let model = withDependencies {
    ///   $0.pasteboard = .withUniqueName()
    /// } operation: {
    ///   FeatureModel()
    /// }
    ///
    /// // Make assertions with model...
    /// ```
    public var pasteboard: UIPasteboard {
      get { self[PasteboardKey.self] }
      set { self[PasteboardKey.self] = newValue }
    }

    private struct PasteboardKey: DependencyKey {
      static let liveValue = UIPasteboard.general
    }
  }
#endif
