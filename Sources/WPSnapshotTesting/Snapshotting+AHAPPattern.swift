import SnapshotTesting
import WPHaptics

extension Snapshotting where Value == AHAPPattern, Format == String {
  /// A snapshot strategy for comparing AHAP Pattern files.
  public static var ahap: Self {
    var snapshotting = SimplySnapshotting.lines.pullback { (pattern: Value) in
      String(decoding: pattern.data(format: .prettyJson), as: UTF8.self)
    }
    snapshotting.pathExtension = "ahap"
    return snapshotting
  }
}
