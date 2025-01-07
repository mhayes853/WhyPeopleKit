import CasePaths
import Foundation

/// A generic type to use in reducers for SwiftUI file dialog interations.
@CasePathable
public enum FileDialogAction: Sendable, Equatable {
  case success([URL])
  case failure

  public init(_ result: Result<URL, any Error>) {
    switch result {
    case let .success(url): self = .success([url])
    case .failure: self = .failure
    }
  }

  public init(_ result: Result<[URL], any Error>) {
    switch result {
    case let .success(urls): self = .success(urls)
    case .failure: self = .failure
    }
  }
}
