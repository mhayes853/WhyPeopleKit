/// A result type returned after an email composer interaction.
public enum EmailComposerResult {
  /// The email message was queued in the user’s outbox.
  case sent
  
  /// The email message was saved in the user’s drafts folder.
  case saved
  
  /// The user canceled the operation.
  case cancelled
  
  /// The email message was not saved or queued, possibly due to an error.
  case failed((any Error)?)
}
