#if canImport(JavaScriptCore)
  import WPJavascriptCore
  import WPFoundation
  import Testing

  @Suite("JSConsoleLogger tests")
  struct JSConsoleLoggerTests {
    private let context = JSContext()!
    private let logger = TestLogger()

    init() {
      self.logger.install(in: self.context)
    }

    @Test("Basic String Log")
    func basicStringLog() {
      self.context.evaluateScript(
        """
        console.log("hello world")
        """
      )
      #expect(self.logger.messages == [LogMessage(level: nil, message: "hello world")])
    }

    @Test("Basic Number Log")
    func basicNumberLog() {
      self.context.evaluateScript(
        """
        console.log(1)
        """
      )
      #expect(self.logger.messages == [LogMessage(level: nil, message: "1")])
    }

    @Test("Basic Object Log")
    func basicObjectLog() {
      self.context.evaluateScript(
        """
        console.log({ a: { b: { c: {} } } })
        """
      )
      #expect(self.logger.messages == [LogMessage(level: nil, message: "{ a: { b: { c: {} } } }")])
    }

    @Test("Basic Object With Constructor Log")
    func basicObjectWithConstructorLog() {
      self.context.evaluateScript(
        """
        console.log({ constructor: "hello" })
        """
      )
      #expect(self.logger.messages == [LogMessage(level: nil, message: "{ constructor: 'hello' }")])
    }

    @Test("Basic Object With Constructor Object Log")
    func basicObjectWithConstructorObjectLog() {
      self.context.evaluateScript(
        """
        console.log({ constructor: { a: "world" } })
        """
      )
      #expect(
        self.logger.messages == [LogMessage(level: nil, message: "{ constructor: { a: 'world' } }")]
      )
    }

    @Test("Basic Numeric Object Log")
    func basicNumericObjectLog() {
      self.context.evaluateScript(
        """
        console.log({ a: { 1: { 2: {} } } })
        """
      )
      #expect(
        self.logger.messages == [LogMessage(level: nil, message: "{ a: { '1': { '2': {} } } }")]
      )
    }

    @Test("Basic Object Log toString")
    func basicObjectLogToString() {
      self.context.evaluateScript(
        """
        console.log({ a: { b: { c: {} } } }.toString())
        """
      )
      #expect(self.logger.messages == [LogMessage(level: nil, message: "[object Object]")])
    }

    @Test("Basic Function Log")
    func basicFunctionLog() {
      self.context.evaluateScript(
        """
        const foo = () => 1 + 1
        console.log(foo)
        """
      )
      #expect(self.logger.messages == [LogMessage(level: nil, message: "[Function: foo]")])
    }

    @Test("Basic Anonymous Function Log")
    func basicAnonymousFunctionLog() {
      self.context.evaluateScript(
        """
        console.log(() => 1 + 1)
        """
      )
      #expect(self.logger.messages == [LogMessage(level: nil, message: "[Function: (anonymous)]")])
    }

    @Test("Basic Function toString Log")
    func basicFunctionToStringLog() {
      self.context.evaluateScript(
        """
        const foo = () => 1 + 1
        console.log(foo.toString())
        """
      )
      #expect(self.logger.messages == [LogMessage(level: nil, message: "() => 1 + 1")])
    }

    @Test("Basic Class Instance Log")
    func basicClassInstanceLog() {
      self.context.evaluateScript(
        """
        class X {
          bar
          foo() {}
        }
        console.log(new X())
        """
      )
      #expect(
        self.logger.messages == [LogMessage(level: nil, message: "class X { bar: undefined }")]
      )
    }

    @Test("Basic Class Private Instance Variable Log")
    func basicClassPrivateInstanceVariableLog() {
      self.context.evaluateScript(
        """
        class X {
          #bar
          foo() {}
        }
        console.log(new X())
        """
      )
      #expect(
        self.logger.messages == [LogMessage(level: nil, message: "class X {}")]
      )
    }

    @Test("Basic Class Constructor Log")
    func basicClassConstructorLog() {
      self.context.evaluateScript(
        """
        class X {
          bar
          foo() {}
        }
        console.log(X)
        """
      )
      #expect(self.logger.messages == [LogMessage(level: nil, message: "[class X]")])
    }

    @Test("Basic Nested Class Constructor Log")
    func basicNestedClassConstructorLog() {
      self.context.evaluateScript(
        """
        class Y {
          foo
        }
        class X {
          bar
          y
          foo() {}
        }
        const x = new X()
        x.y = new Y()
        x.bar = { a: "bar" }
        console.log(x)
        """
      )
      #expect(
        self.logger.messages == [
          LogMessage(
            level: nil,
            message: "class X { bar: { a: 'bar' }, y: class Y { foo: undefined } }"
          )
        ]
      )
    }

    @Test(
      "Basic Primitive Class Constructor Log",
      arguments: [
        "Set", "Array", "Map", "WeakSet", "Function", "Object", "Promise", "WeakMap", "Date"
      ]
    )
    func basicPrimitiveClassConstructorLog(name: String) {
      self.context.evaluateScript(
        """
        console.log(\(name))
        """
      )
      #expect(self.logger.messages == [LogMessage(level: nil, message: "[class \(name)]")])
    }

    @Test("Basic Class toString Log")
    func basicClassToStringLog() {
      self.context.evaluateScript(
        """
        class X {
          bar
          foo() {}
        }
        console.log(X.toString())
        """
      )
      let message = """
        class X {
          bar
          foo() {}
        }
        """
      #expect(self.logger.messages == [LogMessage(level: nil, message: message)])
    }

    @Test("Basic Proxy Log")
    func basicProxyLog() {
      self.context.evaluateScript(
        """
        class X {
          bar
          foo() {}
        }
        console.log(new Proxy(new X(), () => new X()))
        """
      )
      #expect(
        self.logger.messages == [LogMessage(level: nil, message: "class X { bar: undefined }")]
      )
    }

    @Test("Basic Null Log")
    func basicNullLog() {
      self.context.evaluateScript(
        """
        console.log(null)
        """
      )
      #expect(self.logger.messages == [LogMessage(level: nil, message: "null")])
    }

    @Test("Basic Undefined Log")
    func basicUndefinedLog() {
      self.context.evaluateScript(
        """
        console.log(undefined)
        """
      )
      #expect(self.logger.messages == [LogMessage(level: nil, message: "undefined")])
    }

    @Test("Basic Array Log")
    func basicArrayLog() {
      self.context.evaluateScript(
        """
        console.log(["hello", 1, true, "world"])
        """
      )
      #expect(
        self.logger.messages == [LogMessage(level: nil, message: "[ 'hello', 1, true, 'world' ]")]
      )
    }

    @Test("Basic Empty Array Log")
    func basicEmptyArrayLog() {
      self.context.evaluateScript(
        """
        console.log([])
        """
      )
      #expect(
        self.logger.messages == [LogMessage(level: nil, message: "[]")]
      )
    }

    @Test("Basic Nested Array Log")
    func basicNestedArrayLog() {
      self.context.evaluateScript(
        """
        console.log(["hello", ["world"], { a: "world" }])
        """
      )
      #expect(
        self.logger.messages == [
          LogMessage(level: nil, message: "[ 'hello', [ 'world' ], { a: 'world' } ]")
        ]
      )
    }

    @Test("Basic Set Log")
    func basicSetLog() {
      self.context.evaluateScript(
        """
        console.log(new Set([1, "hello", true]))
        """
      )
      #expect(
        self.logger.messages == [LogMessage(level: nil, message: "Set(3) { 1, 'hello', true }")]
      )
    }

    @Test("Basic Set Subclass Log")
    func basicSetSubclassLog() {
      self.context.evaluateScript(
        """
        class SubSet extends Set {}
        console.log(new SubSet([1, "hello", true]))
        """
      )
      #expect(
        self.logger.messages == [LogMessage(level: nil, message: "SubSet(3) { 1, 'hello', true }")]
      )
    }

    @Test("Basic Empty Set Log")
    func basicEmptySetLog() {
      self.context.evaluateScript(
        """
        console.log(new Set())
        """
      )
      #expect(
        self.logger.messages == [LogMessage(level: nil, message: "Set(0) {}")]
      )
    }

    @Test("Basic Map Log")
    func basicMapLog() {
      self.context.evaluateScript(
        """
        console.log(new Map([["foo", 2], ["bar", "baz"], [2, "abc"], [{ a: "p" }, true]]))
        """
      )
      #expect(
        self.logger.messages == [
          LogMessage(
            level: nil,
            message: "Map(4) { 'foo' => 2, 'bar' => 'baz', 2 => 'abc', { a: 'p' } => true }"
          )
        ]
      )
    }

    @Test("Basic Map Subclass Log")
    func basicMapSubclassLog() {
      self.context.evaluateScript(
        """
        class SubMap extends Map {}
        console.log(new SubMap([["foo", 2], ["bar", "baz"], [2, "abc"], [{ a: "p" }, true]]))
        """
      )
      #expect(
        self.logger.messages == [
          LogMessage(
            level: nil,
            message: "SubMap(4) { 'foo' => 2, 'bar' => 'baz', 2 => 'abc', { a: 'p' } => true }"
          )
        ]
      )
    }

    @Test("Basic Empty Map Log")
    func basicEmptyMapLog() {
      self.context.evaluateScript(
        """
        console.log(new Map())
        """
      )
      #expect(
        self.logger.messages == [LogMessage(level: nil, message: "Map(0) {}")]
      )
    }

    @Test("Basic Symbol Log")
    func basicSymbolLog() {
      self.context.evaluateScript(
        """
        console.log(Symbol.name)
        """
      )
      #expect(
        self.logger.messages == [LogMessage(level: nil, message: "Symbol")]
      )
    }

    @Test("Basic Date Log")
    func basicDateLog() {
      self.context.evaluateScript(
        """
        console.log(new Date("2024-11-14T00:00:00.000Z"))
        """
      )
      #expect(
        self.logger.messages == [LogMessage(level: nil, message: "2024-11-14T00:00:00.000Z")]
      )
    }

    @Test("Basic Variadic Args Log")
    func basicVariadicArgsLog() {
      self.context.evaluateScript(
        """
        console.log(1, "hello", true)
        """
      )
      #expect(
        self.logger.messages == [LogMessage(level: nil, message: "1 hello true")]
      )
    }
  }

  private final class TestLogger: JSConsoleLogger {
    private var _messages = Lock([LogMessage]())
    private let logger = PrintJSConsoleLogger()

    var messages: [LogMessage] {
      self._messages.withLock { $0 }
    }

    func log(level: JSConsoleLoggerLevel?, message: String) {
      self.logger.log(level: level, message: message)
      self._messages.withLock { $0.append(LogMessage(level: level, message: message)) }
    }
  }

  private struct LogMessage: Hashable, Sendable {
    let level: JSConsoleLoggerLevel?
    let message: String
  }
#endif
