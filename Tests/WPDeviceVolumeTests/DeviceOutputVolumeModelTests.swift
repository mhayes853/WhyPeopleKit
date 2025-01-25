import ConcurrencyExtras
import Testing
import WPDeviceVolume
import WPFoundation

@MainActor
@Suite("DeviceOutputVolumeModel tests")
struct DeviceOutputVolumeModelTests {
  @Test("Consumes Sequence of Status Updates")
  func consumeStatusUpdates() async {
    let outputVolume = TestDeviceOutputVolume()
    let model = DeviceOutputVolumeModel(outputVolume)

    var status = DeviceOutputVolumeStatus(outputVolume: 0.5)
    await outputVolume.send(result: .success(status))
    #expect(model.status == status)

    status = DeviceOutputVolumeStatus(outputVolume: 0.2)
    await outputVolume.send(result: .success(status))
    #expect(model.status == status)
  }

  @Test("Forwards Error from DeviceOutputVolume")
  func forwardsError() async {
    let outputVolume = TestDeviceOutputVolume()
    let model = DeviceOutputVolumeModel(outputVolume)

    #expect(model.error == nil)

    struct SomeError: Equatable, Error {}
    await outputVolume.send(result: .failure(SomeError()))
    #expect((model.error as? SomeError) == SomeError())
  }

  @Test("Error When Failing to Create Output Volume")
  func failsOutputVolumeCreation() {
    struct SomeError: Equatable, Error {}
    let model = DeviceOutputVolumeModel { () throws -> TestDeviceOutputVolume in throw SomeError() }
    #expect((model.error as? SomeError) == SomeError())
  }

  @Test("Unsubscribes When Deinited")
  func unsubscribes() {
    let volume = CheckUnsubscribeVolume()
    do { _ = DeviceOutputVolumeModel(volume) }
    volume.didUnsub.withLock { #expect($0) }
  }

  @Test("No Retain Cycles")
  func noRetainCycles() {
    let outputVolume = TestDeviceOutputVolume()
    var model: DeviceOutputVolumeModel? = DeviceOutputVolumeModel(outputVolume)
    weak var weakModel: DeviceOutputVolumeModel?
    weakModel = model
    model = nil
    #expect(weakModel == nil)
  }
}

private final class CheckUnsubscribeVolume: DeviceOutputVolume, Sendable {
  let didUnsub = Lock(false)

  func subscribe(
    _ callback: @escaping @Sendable (Result<DeviceOutputVolumeStatus, any Error>) -> Void
  ) -> DeviceOutputVolumeSubscription {
    DeviceOutputVolumeSubscription { self.didUnsub.withLock { $0 = true } }
  }
}
