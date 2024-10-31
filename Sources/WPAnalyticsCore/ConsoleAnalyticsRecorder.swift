import Logging
import os

// MARK: - ConsoleAnalyticsRecorder

/// An ``AnalyticsRecordable`` conformance that logs events to the console in DEBUG build.
public struct ConsoleAnalyticsRecorder: AnalyticsRecordable, Sendable {
  private let console: any Console

  /// Creates a console analytics recorder.
  ///
  /// - Parameter console: A ``Console`` instance, defaults to standard output.
  public init(console: some Console = .standardOutput) {
    self.console = console
  }

  public func record(event: AnalyticsEvent) {
    #if DEBUG
      self.console.print("[Analytics]: \(event).")
    #endif
  }
}

// MARK: - Printer

extension ConsoleAnalyticsRecorder {
  /// A console to print analytic events to.
  public protocol Console: Sendable {
    /// Prints the analytics event formatted as a string.
    ///
    /// - Parameter formattedEvent: A string formatted analytics event.
    func print(_ formattedEvent: String)
  }
}

// MARK: - StandardOutputAnalyticsConsole

/// A console that prints to standard output.
public struct StandardOutputAnalyticsConsole: ConsoleAnalyticsRecorder.Console {
  public init() {}

  public func print(_ string: String) {
    Swift.print(string)
  }
}

extension ConsoleAnalyticsRecorder.Console where Self == StandardOutputAnalyticsConsole {
  /// A console that prints to standard output.
  public static var standardOutput: Self {
    StandardOutputAnalyticsConsole()
  }
}

// MARK: - SwiftLogAnalyticsConsole

/// A console that logs to a swift-log `Logger`.
public struct SwiftLogAnalyticsConsole: ConsoleAnalyticsRecorder.Console {
  private let logger: Logging.Logger
  private let level: Logging.Logger.Level

  /// Creates a console that logs to a swift-log `Logger`.
  ///
  /// - Parameters:
  ///   - logger: The `Logger` to use.
  ///   - level: The level at which `Logger` logs.
  public init(logger: Logging.Logger, level: Logging.Logger.Level = .info) {
    self.logger = logger
    self.level = level
  }

  public func print(_ formattedEvent: String) {
    self.logger.log(level: self.level, "\(formattedEvent)")
  }
}

extension ConsoleAnalyticsRecorder.Console where Self == SwiftLogAnalyticsConsole {
  /// A console that logs to a swift-log `Logger`.
  ///
  /// - Parameters:
  ///   - logger: The `Logger` to use.
  ///   - level: The level at which `Logger` logs.
  public static func swiftLog(logger: Logging.Logger, level: Logging.Logger.Level = .info) -> Self {
    SwiftLogAnalyticsConsole(logger: logger, level: level)
  }
}

// MARK: - OSLogAnalyticsConsole

/// A console that logs to an OSLog `Logger`.
public struct OSLogAnalyticsConsole: ConsoleAnalyticsRecorder.Console {
  private let logger: os.Logger
  private let level: OSLogType

  /// Creates a console that logs to a swift-log `Logger`.
  ///
  /// - Parameters:
  ///   - logger: The `Logger` to use.
  ///   - level: The level at which `Logger` logs.
  public init(logger: os.Logger, level: OSLogType = .info) {
    self.logger = logger
    self.level = level
  }

  public func print(_ formattedEvent: String) {
    self.logger.log(level: self.level, "\(formattedEvent)")
  }
}

extension ConsoleAnalyticsRecorder.Console where Self == OSLogAnalyticsConsole {
  /// A console that logs to an OSLog `Logger`.
  ///
  /// - Parameters:
  ///   - logger: The `Logger` to use.
  ///   - level: The level at which `Logger` logs.
  public static func osLog(logger: os.Logger, level: OSLogType = .info) -> Self {
    OSLogAnalyticsConsole(logger: logger, level: level)
  }
}

// MARK: - Extension

extension AnalyticsRecordable where Self == ConsoleAnalyticsRecorder {
  /// An ``AnalyticsRecordable`` conformance that logs events to the console.
  public static var console: Self {
    ConsoleAnalyticsRecorder()
  }
}
