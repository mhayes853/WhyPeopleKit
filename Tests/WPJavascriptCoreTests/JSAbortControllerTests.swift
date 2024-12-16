#if canImport(JavaScriptCore)
  import WPJavascriptCore
  import Testing
  import CustomDump
  import Clocks

  @Suite("JSAbortController tests")
  struct JSAbortControllerTests {
    private let context = JSContext()!
    private let testClock = TestClock()

    init() throws {
      let clock = self.testClock
      try self.context.install([
        .abortController { try await clock.sleep(for: .seconds($0)) },
        .consoleLogging
      ])
    }

    @Test("Initialization")
    func initialize() {
      let value = self.context.evaluateScript(
        """
        new AbortController()
        """
      )
      let object = self.context.objectForKeyedSubscript("AbortController")
      expectNoDifference(value?.isInstance(of: object), true)
    }

    @Test("Signal is Not Aborted Initially")
    func notInitiallyAborted() {
      let value = self.context.evaluateScript(
        """
        const a = new AbortController()
        a.signal.aborted
        """
      )
      expectNoDifference(value?.toBool(), false)
      expectNoDifference(value?.isUndefined, false)
    }

    @Test("Signal is Aborted After Aborting")
    func abort() {
      let value = self.context.evaluateScript(
        """
        const a = new AbortController()
        a.abort()
        a.signal.aborted
        """
      )
      expectNoDifference(value?.toBool(), true)
      expectNoDifference(value?.isUndefined, false)
    }

    @Test("Signal Aborts With Reason")
    func abortWithReason() {
      let value = self.context.evaluateScript(
        """
        const a = new AbortController()
        a.abort("Test")
        a.signal.reason
        """
      )
      expectNoDifference(value?.toString(), "Test")
    }

    @Test("Throws If Aborted")
    func throwsIfAborted() {
      let value = self.context.evaluateScript(
        """
        const results = []
        const a = new AbortController()

        const check = () => {
          try {
            a.signal.throwIfAborted()
            results.push(null)
          } catch (e) {
            results.push({ reason: e })
          }
        }
        check()
        a.abort("Test")
        check()
        results
        """
      )
      expectNoDifference(value?.toArray().count, 2)
      expectNoDifference(value?.atIndex(0).isNull, true)
      expectNoDifference(value?.atIndex(1).objectForKeyedSubscript("reason").toString(), "Test")
    }

    @Test("Throws If Aborted Without Reason")
    func throwsIfAbortedWithoutReason() throws {
      let value = self.context.evaluateScript(
        """
        const results = []
        const a = new AbortController()

        const check = () => {
          try {
            a.signal.throwIfAborted()
            results.push(null)
          } catch (e) {
            results.push({ reason: e })
          }
        }
        check()
        a.abort()
        check()
        results
        """
      )
      expectNoDifference(value?.toArray().count, 2)
      expectNoDifference(value?.atIndex(0).isNull, true)
      let domException = try #require(self.context.objectForKeyedSubscript("DOMException"))
      let reason = try #require(value?.atIndex(1)?.objectForKeyedSubscript("reason"))
      #expect(reason.isInstance(of: domException))
      expectNoDifference(
        reason.objectForKeyedSubscript("message").toString(),
        "signal is aborted without reason"
      )
      expectNoDifference(
        reason.objectForKeyedSubscript("name").toString(),
        "AbortError"
      )
    }

    @Test("Does Not Signal When Not Aborted")
    func notSignalWhenNotAborted() {
      let value = self.context.evaluateScript(
        """
        let result
        const a = new AbortController()
        a.signal.onabort = (e) =>  result = e.target.reason
        result
        """
      )
      expectNoDifference(value?.isUndefined, true)
    }

    @Test("Signals Abort Signal When Aborted")
    func signalsWhenAborted() {
      let value = self.context.evaluateScript(
        """
        let result
        const a = new AbortController()
        a.signal.onabort = (e) => result = e.target.reason
        a.abort("Test")
        result
        """
      )
      expectNoDifference(value?.toString(), "Test")
    }

    @Test("Only Aborts Once")
    func abortsOnce() {
      let value = self.context.evaluateScript(
        """
        const results = []
        const a = new AbortController()
        a.signal.onabort = (e) => results.push(e.target.reason)
        a.abort()
        a.abort()
        results
        """
      )
      expectNoDifference(value?.toArray().count, 1)
    }

    @Test("Signals Event Listener When Aborted")
    func signalsEventListenerWhenAborted() {
      let value = self.context.evaluateScript(
        """
        const results = []
        const a = new AbortController()
        a.signal.addEventListener("abort", (e) =>  results.push(e.target.reason))
        a.signal.addEventListener("abort", (e) =>  results.push(e.target.reason))
        a.abort("Test")
        results
        """
      )
      expectNoDifference(value?.toArray().count, 2)
      expectNoDifference(value?.atIndex(0).toString(), "Test")
      expectNoDifference(value?.atIndex(1).toString(), "Test")
    }

    @Test("Does Not Observe Other Non-Abort Events")
    func nonAbortEvents() {
      let value = self.context.evaluateScript(
        """
        const results = []
        const a = new AbortController()
        a.signal.addEventListener("foo", (e) => results.push(e.target.reason))
        a.abort()
        results
        """
      )
      expectNoDifference(value?.toArray().count, 0)
      expectNoDifference(value?.isUndefined, false)
    }

    @Test("Unsubscribes from Event Listener")
    func unsubscribes() {
      let value = self.context.evaluateScript(
        """
        const results = []
        const a = new AbortController()
        const listener = (e) => results.push(e.target.reason)
        a.signal.addEventListener("abort", listener)
        a.signal.removeEventListener("abort", listener)
        a.abort("Test")
        results
        """
      )
      expectNoDifference(value?.toArray().count, 0)
      expectNoDifference(value?.isUndefined, false)
    }

    @Test("Constructor Names")
    func constructorNames() {
      let value = self.context.evaluateScript(
        """
        const a = new AbortController()
        const names = [a.constructor.name, a.signal.constructor.name]
        names
        """
      )
      expectNoDifference(value?.atIndex(0).toString(), "AbortController")
      expectNoDifference(value?.atIndex(1).toString(), "AbortSignal")
    }

    @Test("Does not Log Internal Class Variables")
    func doesNotLogVars() throws {
      let logger = TestLogger()
      let context = JSContext()!
      try context.install([.abortController, logger])

      context.evaluateScript(
        """
        const a = new AbortController()
        console.log(a, a.signal)
        """
      )

      expectNoDifference(
        logger.messages,
        [
          LogMessage(level: nil, message: "class AbortController {} class AbortSignal {}")
        ]
      )
    }

    @Test("Creates a Signal in an Aborted State")
    func abortedState() {
      let value = self.context.evaluateScript(
        """
        const signal = AbortSignal.abort("test")
        signal
        """
      )
      expectNoDifference(value?.objectForKeyedSubscript("aborted")?.toBool(), true)
      expectNoDifference(value?.objectForKeyedSubscript("reason")?.toString(), "test")
    }

    @Test("Signal is Non-Constructable")
    func nonConstructableSignal() {
      let value = self.context.evaluateScript(
        """
        new AbortSignal()
        """
      )
      expectNoDifference(value?.isUndefined, true)
    }

    @Test("Abort Signal Any Creates Dependency Between Signals")
    func signalDependencies() {
      let value = self.context.evaluateScript(
        """
        let result
        const a = new AbortController()
        const b = new AbortController()
        const signal = AbortSignal.any([a.signal, b.signal])
        signal.addEventListener("abort", (e) => result = e.target.reason)
        b.abort("test")
        const values = [signal.aborted, a.signal.aborted, b.signal.aborted, result, signal.reason]
        values
        """
      )
      expectNoDifference(value?.atIndex(0).toBool(), true)
      expectNoDifference(value?.atIndex(1).toBool(), false)
      expectNoDifference(value?.atIndex(2).toBool(), true)
      expectNoDifference(value?.atIndex(3).toString(), "test")
      expectNoDifference(value?.atIndex(4).toString(), "test")
    }

    @Test("Dependent Signal is Aborted When Dependency is Aborted")
    func abortedDependency() {
      let value = self.context.evaluateScript(
        """
        const a = AbortSignal.abort()
        const b = new AbortController()
        const signal = AbortSignal.any([a, b.signal])
        signal.aborted
        """
      )
      expectNoDifference(value?.toBool(), true)
    }

    @Test("Dependent Signal Uses First Aborted Signal Reason")
    func firstAbortedReason() {
      let value = self.context.evaluateScript(
        """
        const a = AbortSignal.abort("foo")
        const b = AbortSignal.abort("bar")
        const signal = AbortSignal.any([a, b])
        signal.reason
        """
      )
      expectNoDifference(value?.toString(), "foo")
    }

    @Test("Any Must Take AbortSignal Instances")
    func anyMustTakeSignalInstances() {
      expectErrorMessage(
        js: """
          const signal = AbortSignal.any([""])
          """,
        message:
          "Failed to execute \'any\' on \'AbortSignal\': Failed to convert value to \'AbortSignal\'.",
        in: self.context
      )
    }

    @Test("Signal Aborts After Timeout")
    func abortsAfterTimeout() async throws {
      let promise = try #require(
        self.context
          .evaluateScript(
            """
            new Promise((resolve) => {
              const signal = AbortSignal.timeout(1000)
              signal.onabort = (e) => resolve(e.target.reason)
            })
            """
          )
          .toPromise()
      )
      await self.testClock.advance(by: .seconds(1))
      let value = try await promise.resolvedValue
      expectNoDifference(value.objectForKeyedSubscript("name").toString(), "TimeoutError")
      expectNoDifference(value.objectForKeyedSubscript("message").toString(), "signal timed out")
    }
  }
#endif
