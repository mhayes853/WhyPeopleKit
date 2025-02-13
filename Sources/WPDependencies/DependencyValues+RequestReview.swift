#if canImport(StoreKit) && canImport(SwiftUI)
  import StoreKit
  import SwiftUI
  import Dependencies

  // MARK: - RequestReviewEffect

  public struct RequestReviewEffect: Sendable {
    private let request: @Sendable @MainActor () -> Void

    public init(request: @escaping @MainActor @Sendable () -> Void) {
      self.request = request
    }
  }

  extension RequestReviewEffect {
    @MainActor
    public func callAsFunction() {
      self.request()
    }
  }

  // MARK: - DependencyKey

  extension DependencyValues {
    /// A dependency that requests a review.
    @available(iOS 16, macOS 13, tvOS 16, watchOS 9, *)
    public var requestReview: RequestReviewEffect {
      get { self[RequestReviewKey.self] }
      set { self[RequestReviewKey.self] = newValue }
    }
  }

  @available(iOS 16, macOS 13, tvOS 16, watchOS 9, *)
  private enum RequestReviewKey: DependencyKey {
    static var liveValue: RequestReviewEffect {
      RequestReviewEffect {
        EnvironmentValues().requestReview()
      }
    }

    static var testValue: RequestReviewEffect {
      RequestReviewEffect {
        reportIssue("Unimplemented: @Dependency(\\.requestReview)")
      }
    }
  }
#endif
