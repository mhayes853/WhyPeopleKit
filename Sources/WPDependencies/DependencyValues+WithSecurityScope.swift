import Dependencies
import Foundation

// MARK: - WithSecurityScope

/// A dependency that allows control over URL security scope access.
public struct WithSecurityScope: Sendable {
  let startAccessing: @Sendable (URL) -> Bool
  let stopAccessing: @Sendable (URL) -> Void

  public func callAsFunction<T>(
    url: URL,
    perform work: () throws -> T
  ) throws -> T {
    guard self.startAccessing(url) else { throw SecurityScopeError() }
    defer { self.stopAccessing(url) }
    return try work()
  }

  public func callAsFunction<T>(
    url: URL,
    perform work: () async throws -> T
  ) async throws -> T {
    guard self.startAccessing(url) else { throw SecurityScopeError() }
    defer { self.stopAccessing(url) }
    return try await work()
  }
}

// MARK: - Security Scope Error

public struct SecurityScopeError: Error {}

// MARK: - DependencyKey Conformance

extension WithSecurityScope: DependencyKey {
  public static let alwaysAccessible = Self { _ in
    true
  } stopAccessing: { _ in
  }

  public static let neverAccessible = Self { _ in
    false
  } stopAccessing: { _ in
  }

  public static let liveValue = Self {
    $0.startAccessingSecurityScopedResource()
  } stopAccessing: {
    $0.stopAccessingSecurityScopedResource()
  }

  public static let testValue = Self.alwaysAccessible
}

// MARK: - Dependency Value

extension DependencyValues {
  /// A dependency that allows control over URL security scope access.
  public var withSecurityScope: WithSecurityScope {
    get { self[WithSecurityScope.self] }
    set { self[WithSecurityScope.self] = newValue }
  }
}
