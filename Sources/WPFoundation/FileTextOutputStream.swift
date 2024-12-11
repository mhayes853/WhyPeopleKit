#if canImport(Darwin)
  import Darwin
#else
  @preconcurrency import Glibc
#endif

// MARK: - StandardTextOutputStream

/// A `TextOutputStream` that writes to a FILE pointer.
public struct FileTextOutputStream: TextOutputStream {
  private let file: UnsafeMutablePointer<FILE>

  /// Creates an output stream that writes to the specified FILE pointer.
  /// 
  /// - Parameter file: A FILE pointer.
  public init(file: UnsafeMutablePointer<FILE>) {
    self.file = file
  }

  public func write(_ string: String) {
    guard !string.isEmpty else { return }
    fputs(string, self.file)
  }
}

extension TextOutputStream where Self == FileTextOutputStream {
  /// An output stream that writes to stdout.
  public static var stdout: Self { FileTextOutputStream(file: _stdout) }

  /// An output stream that writed to stderr.
  public static var stderr: Self { FileTextOutputStream(file: _stderr) }
}

#if canImport(Darwin)
  private nonisolated(unsafe) let _stdout = stdout
  private nonisolated(unsafe) let _stderr = stderr
#else 
  private nonisolated(unsafe) let _stdout = stdout!
  private nonisolated(unsafe) let _stderr = stderr!
#endif
