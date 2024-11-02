import WPFoundation

package var mutedSoundURL: URL {
  Bundle.module.assumingURL(forResource: "muted-sound", withExtension: "aiff")
}
