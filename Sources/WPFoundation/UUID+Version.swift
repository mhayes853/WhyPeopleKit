import Foundation

extension UUID {
  /// The version number of this UUID.
  @inlinable
  public var version: Int {
    Int(self.uuid.6 >> 4)
  }
}
