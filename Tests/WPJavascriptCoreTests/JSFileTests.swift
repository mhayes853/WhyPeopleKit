#if canImport(JavaScriptCore)
  @preconcurrency import WPJavascriptCore
  import Testing
  import CustomDump

  @Suite("JSFile tests")
  struct JSFileTests {
    private let context = JSContext()!

    init() {
      self.context.install([.consoleLogging, .fetch])
      self.context.exceptionHandler = { _, value in print(value) }
    }

    @Test(
      "Cannot Construct from a Non-Iterable Value",
      arguments: [
        """
        new File("", "foo.txt")
        """,
        """
        new File(true, "foo.txt")
        """,
        """
        new File(1, "foo.txt")
        """,
        """
        new File({ foo: "bar", a: 2 }, "foo.txt")
        """,
        """
        class C {}
        new File(new C(), "foo.txt")
        """
      ]
    )
    func nonIterable(initObject: String) {
      expectErrorMessage(
        js: initObject,
        message:
          "Failed to construct 'File': The provided value cannot be converted to a sequence.",
        in: self.context
      )
    }

    @Test("Cannot Construct Without Name")
    func noName() {
      expectErrorMessage(
        js: "new File([])",
        message: "Failed to construct 'File': 2 arguments required, but only 1 present.",
        in: self.context
      )
    }

    @Test("Cannot Construct Without Contents")
    func noContents() {
      expectErrorMessage(
        js: "new File()",
        message: "Failed to construct 'File': 2 arguments required, but only 0 present.",
        in: self.context
      )
    }

    @Test("Cannot Construct With Invalid Options")
    func invalidOptions() {
      expectErrorMessage(
        js: "new File([\"foo\"], \"foo.txt\", \"f\")",
        message: "Failed to construct 'File': The provided value is not of type 'FilePropertyBag'.",
        in: self.context
      )
    }

    @Test("Construct With Last Modified", arguments: ["new Date(10)", "10"])
    func lastModified(initObject: String) async {
      let value = self.context.evaluateScript(
        "new File([], \"test.txt\", { lastModified: \(initObject) })"
      )
      expectNoDifference(value?.objectForKeyedSubscript("lastModified").toInt32(), 10)
    }

    @Test("Construct With Numeric Name")
    func numericName() async {
      let value = self.context.evaluateScript(
        """
        new File([], 1, { type: "application/json" }).name
        """
      )
      expectNoDifference(value?.toString(), "1")
    }

    @Test(
      "Text",
      arguments: [
        ("new File(new Blob([\"foo\"]), \"foo.txt\")", "foo"),
        ("new File([], \"foo.txt\")", ""),
        ("new File([\"foo\"], \"foo.txt\")", "foo"),
        ("new File([\"foo\", \"bar\"], \"foo.txt\")", "foobar"),
        ("new File(new Uint8Array(10), \"foo.txt\")", "0000000000"),
        (
          "new File(new Headers([[\"Key\", \"Value\"], [\"K\", \"V\"]]), \"foo.txt\")",
          "key,Valuek,V"
        )
      ]
    )
    func textFromIterable(initObject: String, expected: String) async throws {
      let value = try await #require(
        self.context.evaluateScript("\(initObject).text()").toPromise()
      )
      .resolvedValue
      expectNoDifference(value.toString(), expected)
    }

    @Test("File exists")
    func exists() {
      let value = self.context.objectForKeyedSubscript("File")
      expectNoDifference(value?.isUndefined, false)
    }

    @Test("Instance of Blob")
    func instanceOfBlob() {
      let value = self.context.evaluateScript(
        """
        new File([], "foo.txt") instanceof Blob
        """
      )
      expectNoDifference(value?.toBool(), true)
    }
  }
#endif
