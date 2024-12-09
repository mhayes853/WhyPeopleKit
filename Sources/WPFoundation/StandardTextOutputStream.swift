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

#if canImport(Darwin)
  extension TextOutputStream where Self == StandardTextOutputStream {
    public static var stdout: Self { StandardTextOutputStream(file: Darwin.stdout) }
    public static var stderr: Self { StandardTextOutputStream(file: Darwin.stderr) }
  }
#else
  extension TextOutputStream where Self == StandardTextOutputStream {
    public static var stdout: Self { StandardTextOutputStream(file: Glibc.stdout!) }
    public static var stderr: Self { StandardTextOutputStream(file: Glibc.stderr!) }
  }
#endif
