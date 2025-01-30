#if canImport(JavaScriptCore)
  @preconcurrency import JavaScriptCore
  import WPFoundation

  // MARK: - JSVirtualMachinePool

  /// A class that manages a pool of `JSVirtualMachine`s that can be shared amongst `JSContext`s.
  ///
  /// Each `JSVirtualMachine` is allocated a JS Heap, and performs garbage collection. For
  /// applications with few `JSContext` instances, it can be appropriate to create separate
  /// `JSVirtualMachine`s for each `JSContext` instance.
  ///
  /// However, this can create a large resource overhead for applications with many `JSContext`
  /// instances. Instead, applications with many contexts will want to share a virtual machine
  /// between those contexts, but sharing a single virtual machine shared amongst many contexts
  /// prevents those contexts from running JS code concurrently.
  ///
  /// This class exists as a mechanism for sharing a pool of `JSVirtualMachine`s with multiple
  /// `JSContext`s in order to achieve a balance between concurrent execution and limited resource
  /// overhead. You can call ``virutalMachine`` on the pool to get a virtual machine instance to
  /// create a `JSContext`. Virtual machines are created lazily, and are delegated round-robin
  /// style.
  public final class JSVirtualMachinePool: @unchecked Sendable {
    fileprivate typealias State = (
      index: Int, count: Int, machines: [JSVirtualMachine]
    )

    private let vm: (@Sendable () -> JSVirtualMachine)?
    private let condition = NSCondition()
    private let state: Lock<State>
    private var isCreatingMachineCondition = false

    /// Creates a virutal machine pool.
    ///
    /// - Parameters:
    ///   - count: The maximum number of virtual machines to contain in the pool.
    ///   - vm: A function to create a custom virtual machine that is called every time the pool creates a new `JSVirtualMachine`.
    public init(
      machines count: Int,
      vm: (@Sendable () -> JSVirtualMachine)? = nil
    ) {
      precondition(count > 0, "There must be a minimum of at least 1 virtual machine in the pool.")
      var vms = [JSVirtualMachine]()
      vms.reserveCapacity(count)
      self.vm = vm
      self.state = Lock((index: 0, count: count, machines: vms))
    }
  }

  // MARK: - Accessing a Virtual Machine

  extension JSVirtualMachinePool {
    /// Returns a `JSVirutalMachine` from this pool.
    ///
    /// The virtual machine returned is picked round-robin style.
    ///
    /// - Returns: A `JSVirutalMachine`.
    public func virtualMachine() async -> JSVirtualMachine {
      let transfer = self.state.withLock { state -> UnsafeJSVirtualMachineTransfer? in
        guard self.hasCreatedMaximumMachines(state: state) else { return nil }
        return UnsafeJSVirtualMachineTransfer(vm: self.nextVM(in: &state))
      }
      if let transfer {
        return transfer.vm
      }
      return await withUnsafeContinuation { continuation in
        self.condition.lock()
        while self.isCreatingMachineCondition {
          self.condition.wait()
        }
        self.state.withLock { state in
          if !self.hasCreatedMaximumMachines(state: state) {
            self.isCreatingMachineCondition = true
            Thread.detachNewThread {
              self.condition.lock()
              let vm = self.state.withLock { state in
                let vm = self.vm?() ?? JSVirtualMachine()!
                state.machines.append(vm)
                return vm
              }
              continuation.resume(returning: vm)
              self.isCreatingMachineCondition = false
              self.condition.signal()
              self.condition.unlock()
            }
          } else {
            continuation.resume(returning: self.nextVM(in: &state))
            self.condition.signal()
          }
          self.condition.unlock()
        }
      }
    }

    private func hasCreatedMaximumMachines(state: State) -> Bool {
      state.machines.count < state.count
    }

    private func nextVM(in state: inout State) -> JSVirtualMachine {
      defer { state.index = (state.index + 1) % state.count }
      return state.machines[state.index]
    }
  }

  // MARK: - Helpers

  private struct UnsafeJSVirtualMachineTransfer: @unchecked Sendable {
    let vm: JSVirtualMachine
  }
#endif
