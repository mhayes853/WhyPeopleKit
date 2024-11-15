#if canImport(JavaScriptCore)
  import JavaScriptCore
  import WPFoundation

  // MARK: - JSConsole

  /// A protocol that implements Javascript's the `console.log` family of functions.
  public protocol JSConsoleLogger {
    func log(level: JSConsoleLoggerLevel?, message: String)
  }

  // MARK: - LogLevel

  public enum JSConsoleLoggerLevel: Int, Hashable, Codable, Sendable {
    case trace = 0
    case debug = 1
    case info = 2
    case warn = 3
    case error = 4
  }

  // MARK: - Install

  extension JSConsoleLogger {
    public func install(in context: JSContext) {
      let log: @convention(block) (JSValue) -> Void = {
        self.log(level: nil, message: $0.loggableString())
      }
      context.setObject(log, forPath: "console.log")
    }
  }

  // MARK: - PrintJSConsoleLogger

  public struct PrintJSConsoleLogger: JSConsoleLogger {
    public init() {}

    public func log(level: JSConsoleLoggerLevel?, message: String) {
      var stderr = StandardTextOutputStream.stderr
      switch level {
      case .error: print(message, to: &stderr)
      default: print(message)
      }
    }
  }

  // MARK: - Helpers

  extension JSValue {
    fileprivate func loggableString(isNested: Bool = false) -> String {
      if self.isBoolean {
        return self.toBool() ? "true" : "false"
      } else if self.isUndefined {
        return "undefined"
      } else if self.isNull {
        return "null"
      } else if self.isString {
        return isNested ? "'\(self)'" : "\(self)"
      } else if self.isNumber {
        return "\(self.toNumber().description)"
      } else if self.isDate {
        return DateFormatter.jsString.string(from: self.toDate())
      } else if self.isArray {
        let strings = (0..<self.toArray().count)
          .map { self.atIndex($0).loggableString(isNested: true) }
          .joined(separator: ", ")
        return strings.isEmpty ? "[]" : "[ \(strings) ]"
      } else if self.isSet {
        let className = self.classConstructor?.functionName ?? "Set"
        let size = self.objectForKeyedSubscript("size").toInt32()
        guard size > 0 else { return "\(className)(0) {}" }
        var values = [JSValue]()
        let each: @convention(block) (JSValue) -> Void = {
          values.append($0)
        }
        self.invokeMethod("forEach", withArguments: [unsafeBitCast(each, to: JSValue.self)])
        return
          "\(className)(\(size)) { \(values.map { $0.loggableString(isNested: true) }.joined(separator: ", ")) }"
      } else if self.isMap {
        let className = self.classConstructor?.functionName ?? "Map"
        let size = self.objectForKeyedSubscript("size").toInt32()
        guard size > 0 else { return "\(className)(0) {}" }
        var values = [(key: JSValue, value: JSValue)]()
        let each: @convention(block) (JSValue, JSValue) -> Void = {
          values.append(($1, $0))
        }
        self.invokeMethod("forEach", withArguments: [unsafeBitCast(each, to: JSValue.self)])
        let mapStrings =
          values.map {
            "\($0.key.loggableString(isNested: true)) => \($0.value.loggableString(isNested: true))"
          }
          .joined(separator: ", ")
        return "\(className)(\(size)) { \(mapStrings) }"
      } else if self.isSymbol {
        return "\(self)"
      } else if self.isClassConstructor {
        return "[class \(self.functionName)]"
      } else if self.isFunction {
        return "[Function: \(self.functionName)]"
      } else if let constructor = self.classConstructor {
        let base = "class \(constructor.functionName) "
        return self.objectPropertiesString.isEmpty
          ? "\(base){}" : "\(base){ \(self.objectPropertiesString) }"
      } else {
        return self.objectPropertiesString.isEmpty ? "{}" : "{ \(self.objectPropertiesString) }"
      }
    }

    fileprivate var objectPropertiesString: String {
      (self.instanceVariableNames ?? [])
        .map { ($0, self.objectForKeyedSubscript($0)) }
        .map {
          "\($0.0.jsObjectKeyString): \($0.1?.loggableString(isNested: true) ?? "undefined")"
        }
        .joined(separator: ", ")
    }
  }

  extension JSValue {
    fileprivate var isSet: Bool {
      self.isInstanceOf(className: "Set")
    }

    fileprivate var isFunction: Bool {
      self.isInstanceOf(className: "Function")
    }

    fileprivate var isMap: Bool {
      self.isInstanceOf(className: "Map")
    }

    private func isInstanceOf(className: String) -> Bool {
      self.context.objectForKeyedSubscript(className).map { self.isInstance(of: $0) } ?? false
    }

    fileprivate var isClassConstructor: Bool {
      guard let prototype = self.objectForKeyedSubscript("prototype") else {
        return false
      }
      guard self.isFunction else { return false }
      guard let string = prototype.toString() else {
        // NB: Only Date's constructor seems to hit this case, should there be more checks here?
        return true
      }
      return self.functionName == "Function"
        || (!string.starts(with: "function") && string != "undefined")
    }

    fileprivate var classConstructor: JSValue? {
      self.objectForKeyedSubscript("constructor")
        .flatMap { $0.isClassConstructor && $0.functionName != "Object" ? $0 : nil }
    }

    fileprivate var functionName: String {
      guard let name = self.objectForKeyedSubscript("name").toString() else {
        return "(anonymous)"
      }
      return name.isEmpty ? "(anonymous)" : name
    }

    fileprivate var instanceVariableNames: [String]? {
      let names = self.context.objectForKeyedSubscript("Object")?
        .objectForKeyedSubscript("getOwnPropertyNames")
        .call(withArguments: [self])
      return names?.toArray().map { arr in arr.compactMap { $0 as? String } }
    }
  }

  extension String {
    fileprivate var jsObjectKeyString: String {
      if let int = Int(self) {
        return "'\(int)'"
      }
      return self
    }
  }

  extension DateFormatter {
    fileprivate static let jsString: DateFormatter = {
      let formatter = DateFormatter()
      formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
      formatter.timeZone = TimeZone(identifier: "GMT")
      return formatter
    }()
  }
#endif
