import ConcurrencyExtras
import Testing
import WPDeviceVolume

@MainActor
@Suite("DeviceOutputVolumeModel tests")
struct DeviceOutputVolumeModelTests {
  @Test("Consumes Sequence of Status Updates")
  func consumeStatusUpdates() async {
    let (stream, continuation) = AsyncThrowingStream<DeviceOutputVolumeStatus, Error>.makeStream()
    let model = DeviceOutputVolumeModel(TestDeviceOutputVolume(statusUpdates: stream))
    var status = DeviceOutputVolumeStatus(outputVolume: 0.5)
    continuation.yield(status)
    await Task.megaYield()
    #expect(model.status == status)

    status = DeviceOutputVolumeStatus(outputVolume: 0.2)
    continuation.yield(status)
    await Task.megaYield()
    #expect(model.status == status)
  }

  @Test("Forwards Error from DeviceOutputVolume")
  func forwardsError() async {
    let (stream, continuation) = AsyncThrowingStream<DeviceOutputVolumeStatus, Error>.makeStream()
    let model = DeviceOutputVolumeModel(TestDeviceOutputVolume(statusUpdates: stream))
    #expect(model.error == nil)
    struct SomeError: Equatable, Error {}
    continuation.finish(throwing: SomeError())
    await Task.megaYield()
    #expect((model.error as? SomeError) == SomeError())
  }
}
