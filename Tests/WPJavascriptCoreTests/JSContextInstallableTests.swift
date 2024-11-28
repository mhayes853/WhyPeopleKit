#if canImport(JavaScriptCore)
  import WPJavascriptCore
  import Testing
  import CustomDump

  @Suite("JSContextInstallable tests")
  struct JSContextInstallableTests {
    private let context = JSContext()!
    private let context2 = JSContext()!

    @Test("Installs Deduplicated Installer Multiple Times On Different Contexts")
    func installsOnDifferentContexts() {
      let installer = CounterInstaller()
      let deduplicatedInstaller = installer.deduplicated()
      self.context.install([deduplicatedInstaller])
      self.context2.install([deduplicatedInstaller])
      expectNoDifference(installer.count, 2)
    }

    @Test("Only Installs Deduplicated Installer Once On Same Context")
    func sameInstallKey() {
      let installer = CounterInstaller()
      let deduplicatedInstaller = installer.deduplicated()
      self.context.install([deduplicatedInstaller])
      self.context.install([deduplicatedInstaller])
      expectNoDifference(installer.count, 1)
    }

    @Test("Deduplicates Installers With Same Ids")
    func deduplicatesSameIds() {
      let installer = IdentifiableCounterInstaller()
      installer.id = 1
      let installer2 = IdentifiableCounterInstaller()
      installer2.id = 1
      let deduplicatedInstaller = installer.deduplicated()
      let deduplicatedInstaller2 = installer2.deduplicated()
      self.context.install([deduplicatedInstaller])
      self.context.install([deduplicatedInstaller2])
      expectNoDifference(installer.count, 1)
      expectNoDifference(installer2.count, 0)
    }

    @Test("Installs Installers With Different Ids")
    func duplicatesDifferentIds() {
      let installer = IdentifiableCounterInstaller()
      installer.id = 1
      let installer2 = IdentifiableCounterInstaller()
      installer2.id = 2
      let deduplicatedInstaller = installer.deduplicated()
      let deduplicatedInstaller2 = installer2.deduplicated()
      self.context.install([deduplicatedInstaller])
      self.context.install([deduplicatedInstaller2])
      expectNoDifference(installer.count, 1)
      expectNoDifference(installer2.count, 1)
    }
  }

  private final class CounterInstaller: JSContextInstallable, Identifiable {
    private(set) var count = 0

    func install(in context: JSContext) {
      self.count += 1
    }
  }

  private final class IdentifiableCounterInstaller: JSContextInstallable, Identifiable {
    private(set) var count = 0
    var id: Int?

    func install(in context: JSContext) {
      self.count += 1
    }
  }
#endif
