public enum EmailComposerResult {
  case sent
  case saved
  case cancelled
  case failed((any Error)?)
}
