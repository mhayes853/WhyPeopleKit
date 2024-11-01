import Foundation

extension TimeInterval {
  @available(iOS 16, macOS 13, tvOS 16, watchOS 9, *)
  public init(duration: Duration) {
    let convertedAttoseconds = TimeInterval(duration.components.attoseconds) / 1e18
    self = TimeInterval(duration.components.seconds) + convertedAttoseconds
  }
}
