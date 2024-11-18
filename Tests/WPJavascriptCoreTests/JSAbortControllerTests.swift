#if canImport(JavaScriptCore)
  import WPJavascriptCore
  import Testing
  import CustomDump

  @Suite("JSAbortController tests")
  struct JSAbortControllerTests {
    private let context = JSContext()!

    init() {
      self.context.install([.abortController, .consoleLogging])
      //self.context.exceptionHandler = { _, value in print(value) }
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
    func doesNotLogVars() {
      let logger = TestLogger()
      self.context.install([logger])

      self.context.evaluateScript(
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
  }
#endif
