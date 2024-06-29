import Foundation
import Security
import CryptoKit

// MARK: - Credentials

/// A data type for the code challenge and verifier of an OAuth2 Proof Key for Code Exchange (PKCE)
/// grant type that conforms to RFC 7636.
public struct PKCECredentials: Hashable, Sendable {
  public let codeVerifier: String
  public let codeChallenge: String
  public let challengeMethod: CodeChallengeMethod
  
  /// Initiializes a ``PKCECredentials`` instance from a specified code verifier.
  ///
  /// - Parameters:
  ///   - codeVerifier: A code verifier string that conforms to the format specified in RFC 7636.
  ///   - challengeMethod: The ``CodeChallengeMethod`` to use.
  public init(codeVerifier: String, challengeMethod: CodeChallengeMethod = .sha256) {
    self.codeVerifier = codeVerifier
    self.codeChallenge = challengeMethod.challenge(from: codeVerifier)
    self.challengeMethod = challengeMethod
  }
}

// MARK: - Randomness

extension PKCECredentials {
  /// Attempts to initialize a ``PKCECredentials`` instance by cryptographically generating a code
  /// verifier that conforms to the format in RFC 7636.
  ///
  /// - Parameter challengeMethod: The ``CodeChallengeMethod`` to use.
  public init(challengeMethod: CodeChallengeMethod = .sha256) throws {
    var codeVerifierBuffer = [UInt8](repeating: 0, count: 32)
    let errorCode = SecRandomCopyBytes(kSecRandomDefault, 32, &codeVerifierBuffer)
    guard errorCode == errSecSuccess else { throw SecError(code: errorCode) }
    self.init(
      codeVerifier: Data(codeVerifierBuffer).base64URLEncodedString(),
      challengeMethod: challengeMethod
    )
  }
}

// MARK: - CodeChallengeMethod

extension PKCECredentials {
  /// An enum with the supported code challenge methods for PKCE.
  ///
  /// Always prefer to use ``sha256`` over ``plain`` when possible.
  public enum CodeChallengeMethod: String, Sendable {
    case plain = "plain"
    case sha256 = "S256"
  }
}

extension PKCECredentials.CodeChallengeMethod {
  /// Returns a code challenge string from a specified code verifier string.
  ///
  /// - Parameter verifier: A code verifier string that conforms to the format specified in RFC 7636.
  /// - Returns: A code challenge string.
  public func challenge(from verifier: String) -> String {
    switch self {
    case .plain: verifier
    case .sha256: Data(SHA256.hash(data: verifier.data(using: .ascii)!)).base64URLEncodedString()
    }
  }
}
