#if canImport(Darwin)
  import Darwin
#else
  import Glibc
#endif

// MARK: - StandardTextOutputStream

public struct StandardTextOutputStream: TextOutputStream {
  private let file: UnsafeMutablePointer<FILE>

  public init(file: UnsafeMutablePointer<FILE>) {
    self.file = file
  }

  public func write(_ string: String) {
    guard !string.isEmpty else { return }
    fputs(string, self.file)
  }
}

extension TextOutputStream where Self == StandardTextOutputStream {
  public static var stdout: Self { StandardTextOutputStream(file: _stdout) }
  public static var stderr: Self { StandardTextOutputStream(file: _stderr) }
}

// MARK: - Helpers

private nonisolated(unsafe) let _stdout = stdout
private nonisolated(unsafe) let _stderr = stderr
