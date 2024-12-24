#if !os(linux)
  import Testing
  import WPDependencies
  import WPDeviceVolume
  import WPSharing

  @Suite("DeviceOutputVolumeKey tests")
  struct DeviceOutputVolumeKeyTests {
    @Test("Consumes Sequence of Status Updates")
    func consumeStatusUpdates() async {
      let outputVolume = TestDeviceOutputVolume()
      await withDependencies {
        $0.systemDeviceOutputVolume = outputVolume
      } operation: {
        @SharedReader(.systemDeviceOutputVolume) var volume

        var status = DeviceOutputVolumeStatus(outputVolume: 0.5)
        await outputVolume.send(result: .success(status))
        #expect(volume == status)

        status = DeviceOutputVolumeStatus(outputVolume: 0.2)
        await outputVolume.send(result: .success(status))
        #expect(volume == status)
      }
    }
  }
#endif
