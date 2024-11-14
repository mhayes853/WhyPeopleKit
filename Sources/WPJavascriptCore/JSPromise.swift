#if canImport(JavaScriptCore)
  import WPFoundation
  import IssueReporting
  @preconcurrency import JavaScriptCore

  // MARK: - JSPromise

  public struct JSPromise: Sendable {
    public let value: JSValue

    private init(_ value: JSValue) {
      self.value = value
    }
  }

  // MARK: - Value Init

  extension JSPromise {
    public init?(value: JSValue) {
      guard let promiseConstructor = value.context.objectForKeyedSubscript("Promise") else {
        return nil
      }
      guard value.isInstance(of: promiseConstructor) else { return nil }
      self.value = value
    }
  }

  // MARK: - Resolved Value

  extension JSPromise {
    public var resolvedValue: JSValue {
      get async throws {
        try await withUnsafeThrowingContinuation { continuation in
          self.then {
            continuation.resume(returning: $0)
            return JSValue(undefinedIn: $0.context)
          } onRejected: {
            continuation.resume(throwing: JSPromiseError(value: $0))
            return JSValue(undefinedIn: $0.context)
          }
        }
      }
    }
  }

  // MARK: - Static Init

  extension JSPromise {
    public static func resolve(_ value: Any?, in context: JSContext) -> Self {
      Self(JSValue(newPromiseResolvedWithResult: value, in: context))
    }

    public static func reject(_ value: Any?, in context: JSContext) -> Self {
      Self(JSValue(newPromiseRejectedWithReason: value, in: context))
    }
  }

  // MARK: - Continuation Init

  extension JSPromise {
    public struct Continuation: Sendable {
      private let storage: Storage

      public var context: JSContext { self.storage.context }
      fileprivate var value: JSValue { self.storage.value }

      fileprivate init(context: JSContext) {
        self.storage = Storage(context: context)
      }

      public func resume(resolving value: JSValue) {
        self.storage.resume(resolving: value)
      }

      public func resume(rejecting value: JSValue) {
        self.storage.resume(rejecting: value)
      }
    }

    public init(in context: JSContext, perform fn: @Sendable (Continuation) -> Void) {
      let continuation = Continuation(context: context)
      fn(continuation)
      self.value = continuation.value
    }
  }

  extension JSPromise.Continuation {
    private final class Storage: Sendable {
      private let state:
        Lock<(value: JSValue, resolve: JSValue?, reject: JSValue?, isResumed: Bool)>

      var context: JSContext { self.state.withLock { $0.value.context } }
      var value: JSValue { self.state.withLock { $0.value } }

      init(context: JSContext) {
        self.state = Lock((JSValue(), nil, nil, false))
        self.state.withLock { state in
          withoutActuallyEscaping(
            { (resolve: JSValue?, reject: JSValue?) -> Void in
              state.resolve = resolve
              state.reject = reject
            },
            do: { state.value = JSValue(newPromiseIn: context, fromExecutor: $0) }
          )
        }
      }

      func resume(resolving value: JSValue) {
        self.state.withLock {
          if $0.isResumed {
            jsPromiseContinuationMisuse()
          }
          $0.isResumed = true
          $0.resolve?.call(withArguments: [value])
        }
      }

      func resume(rejecting value: JSValue) {
        self.state.withLock {
          if $0.isResumed {
            jsPromiseContinuationMisuse()
          }
          $0.isResumed = true
          $0.reject?.call(withArguments: [value])
        }
      }
    }
  }

  // MARK: - Instance Methods

  extension JSPromise {
    @discardableResult
    public func then(
      perform fn: @convention(block) @Sendable @escaping (JSValue) -> JSValue,
      onRejected: (@convention(block) @Sendable (JSValue) -> JSValue)? = nil
    ) -> Self {
      var args = [unsafeBitCast(fn, to: JSValue.self)]
      if let onRejected {
        args.append(unsafeBitCast(onRejected, to: JSValue.self))
      }
      return Self(self.value.invokeMethod("then", withArguments: args))
    }

    @discardableResult
    public func `catch`(
      perform fn: @convention(block) @Sendable @escaping (JSValue) -> JSValue
    ) -> Self {
      Self(self.value.invokeMethod("catch", withArguments: [unsafeBitCast(fn, to: JSValue.self)]))
    }

    @discardableResult
    public func finally(
      perform fn: @convention(block) @Sendable @escaping () -> Void
    ) -> Self {
      Self(self.value.invokeMethod("finally", withArguments: [unsafeBitCast(fn, to: JSValue.self)]))
    }
  }

  // MARK: - JSPromiseError

  public struct JSPromiseError: Error {
    public let value: JSValue

    public init(value: JSValue) {
      self.value = value
    }
  }

  // MARK: - JSValue

  extension JSValue {
    public func toPromise() -> JSPromise? {
      JSPromise(value: self)
    }
  }

  // MARK: - Helpers

  private func jsPromiseContinuationMisuse() {
    reportIssue(
      """
      A JSPromise Continuation was resumed more than once.

      Resuming more than once will have no effect on the resolved value or rejected reason.
      """
    )
  }
#endif
