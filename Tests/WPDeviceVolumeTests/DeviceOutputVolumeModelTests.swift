import ConcurrencyExtras
import Testing
import WPDeviceVolume

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
}
