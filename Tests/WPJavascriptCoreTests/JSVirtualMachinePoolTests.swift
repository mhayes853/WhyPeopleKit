#if canImport(JavaScriptCore)
  @preconcurrency import WPJavascriptCore
  import Testing
  import CustomDump

  @Suite("JSVirtualMachinePool tests")
  struct JSVirtualMachinePoolTests {
    @Test("Uses Same Virtual Machine For Contexts When Only 1 Machine Allowed")
    func singleMachinePool() {
      let pool = JSVirtualMachinePool(machines: 1)
      let (c1, c2) = (JSContext(in: pool), JSContext(in: pool))
      expectIdenticalVMs(c1, c2)
    }

    @Test("Performs A Round Robin When Pool Has Multiple Virtual Machines")
    func roundRobin() {
      let pool = JSVirtualMachinePool(machines: 3)
      let (c1, c2, c3, c4) = (
        JSContext(in: pool), JSContext(in: pool), JSContext(in: pool), JSContext(in: pool)
      )
      expectDifferentVMs(c1, c2)
      expectDifferentVMs(c2, c3)
      expectDifferentVMs(c3, c1)
      expectIdenticalVMs(c1, c4)
    }

    @Test("Performs A Round Robin When Pool Has Multiple Virtual Machines When Mapping")
    func roundRobinMapping() {
      let pool = JSVirtualMachinePool(machines: 3)
      let contexts = pool.mapVirtualMachines(0..<4) { _, vm in JSContext(virtualMachine: vm)! }
      expectDifferentVMs(contexts[0], contexts[1])
      expectDifferentVMs(contexts[1], contexts[2])
      expectDifferentVMs(contexts[2], contexts[0])
      expectIdenticalVMs(contexts[0], contexts[3])
    }

    @Test("Supports Custom Virtual Machines")
    func customMachines() {
      let pool = JSVirtualMachinePool(machines: 2) { CustomVM()! }
      let (c1, c2) = (JSContext(in: pool), JSContext(in: pool))
      expectDifferentVMs(c1, c2)
      expectNoDifference(c1.virtualMachine is CustomVM, true)
      expectNoDifference(c2.virtualMachine is CustomVM, true)
    }
  }

  private final class CustomVM: JSVirtualMachine {}

  private func expectIdenticalVMs(_ c1: JSContext, _ c2: JSContext) {
    expectNoDifference(c1.virtualMachine === c2.virtualMachine, true)
  }

  private func expectDifferentVMs(_ c1: JSContext, _ c2: JSContext) {
    expectNoDifference(c1.virtualMachine === c2.virtualMachine, false)
  }
#endif
