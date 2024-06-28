import Foundation
import Security
import CryptoKit

public struct PKCECredentials {}

extension PKCECredentials {
  public enum CodeChallengeMethod: String {
    case plain = "plain"
    case s256 = "S256"
  }
}
