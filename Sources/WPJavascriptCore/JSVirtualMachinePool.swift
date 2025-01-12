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
  public final class JSVirtualMachinePool: Sendable {
    private typealias State = (index: Int, count: Int, machines: [JSVirtualMachine])

    private let vm: (@Sendable () -> JSVirtualMachine)?
    private let vms: Lock<State>

    /// Creates a virutal machine pool.
    ///
    /// - Parameters:
    ///   - count: The maximum number of virtual machines to contain in the pool.
    ///   - vm: A function to create a custom virtual machine that is called every time the pool creates a new `JSVirtualMachine`.
    public init(machines count: Int, vm: (@Sendable () -> JSVirtualMachine)? = nil) {
      precondition(count > 0, "There must be a minimum of at least 1 virtual machine in the pool.")
      var vms = [JSVirtualMachine]()
      vms.reserveCapacity(count)
      self.vm = vm
      self.vms = Lock((index: 0, count: count, machines: vms))
    }
  }

  // MARK: - Accessing a Virtual Machine

  extension JSVirtualMachinePool {
    /// Returns a `JSVirutalMachine` from this pool.
    ///
    /// The virtual machine returned is picked round-robin style.
    ///
    /// Do not repeatedly call this method if your need to create many `JSContext`s at once,
    /// instead call ``mapVirtualMachines``.
    ///
    /// - Returns: A `JSVirutalMachine`.
    public func virtualMachine() -> JSVirtualMachine {
      self.vms.withLock { self.nextVM(state: &$0) }
    }

    /// Creates an array of elements by mapping the specified sequence elements with a
    /// `JSVirtualMachine`.
    ///
    /// - Parameters:
    ///   - sequence: A sequence of data.
    ///   - fn: A function to map an element of `sequence` and a `JSVirtualMachine` to the new element.
    /// - Returns: An array of mapped elements.
    public func mapVirtualMachines<T: Sendable, S: Sequence>(
      _ sequence: S,
      _ fn: @Sendable (S.Element, JSVirtualMachine) throws -> T
    ) rethrows -> [T] {
      try self.vms.withLock { state in
        try sequence.map { try fn($0, self.nextVM(state: &state)) }
      }
    }

    private func nextVM(state: inout State) -> JSVirtualMachine {
      defer { state.index = (state.index + 1) % state.count }
      if state.index < state.machines.count {
        return state.machines[state.index]
      } else {
        let vm = self.vm?() ?? JSVirtualMachine()!
        state.machines.append(vm)
        return vm
      }
    }
  }

  // MARK: - JSContext Init

  extension JSContext {
    public convenience init(in pool: JSVirtualMachinePool) {
      self.init(virtualMachine: pool.virtualMachine())
    }
  }
#endif
