#if canImport(JavaScriptCore)
  import WPJavascriptCore
  import Testing
  import CustomDump

  @Suite("JSContextInstallable tests")
  struct JSContextInstallableTests {
    private let context = JSContext()!

    @Test("Installs Multiple Times When No Install Key Specified")
    func noInstallKey() {
      let installer = CounterInstaller()
      self.context.install([installer])
      self.context.install([installer])
      expectNoDifference(installer.count, 2)
    }

    @Test("Installs Multiple Times When Different Install Keys")
    func differentInstallKeys() {
      let installer = CounterInstaller(installKey: "foo")
      self.context.install([installer])
      installer.installKey = "bar"
      self.context.install([installer])
      expectNoDifference(installer.count, 2)
    }

    @Test("Only Installs Once When Same Key Used In Different Installs")
    func sameInstallKey() {
      let installer = CounterInstaller(installKey: "foo")
      self.context.install([installer])
      self.context.install([installer])
      expectNoDifference(installer.count, 1)
    }

    @Test(
      "Still Installs Other Installables With Same Keys As Long As They Have Not Been Installed Twice"
    )
    func stillInstallsOthers() {
      let installer = CounterInstaller(installKey: "foo")
      let installer2 = CounterInstaller(installKey: "bar")

      self.context.install([installer])
      self.context.install([installer])
      expectNoDifference(installer.count, 1)

      self.context.install([installer2])
      expectNoDifference(installer2.count, 1)

      self.context.install([installer2])
      expectNoDifference(installer2.count, 1)

      self.context.install([installer])
      expectNoDifference(installer.count, 1)
    }

    @Test("Doesn't Install Duplicate Intallables With Same Install From Combination")
    func installsCombinationsSeparately() {
      let installer = CounterInstaller(installKey: "foo")
      let installer2 = CounterInstaller(installKey: "bar")
      let installer3 = combineInstallers([installer, installer2])
      self.context.install([installer3])
      expectNoDifference(installer.count, 1)
      expectNoDifference(installer2.count, 1)

      self.context.install([installer])
      expectNoDifference(installer.count, 1)

      self.context.install([installer2])
      expectNoDifference(installer2.count, 1)

      self.context.install([installer3])
      expectNoDifference(installer.count, 1)
      expectNoDifference(installer2.count, 1)
    }
  }

  private final class CounterInstaller: JSContextInstallable {
    private(set) var count = 0
    var installKey: AnyHashable?

    init(installKey: AnyHashable? = nil) {
      self.installKey = installKey
    }

    func install(in context: JSContext) {
      self.count += 1
    }
  }
#endif
