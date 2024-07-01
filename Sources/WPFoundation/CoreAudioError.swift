import CoreAudio

/// A wrapper `Error` conformance for error codes returned by CoreAudio.
public struct CoreAudioError: Error {
  public let status: OSStatus
  
  public init(_ status: OSStatus) {
    self.status = status
  }
}
