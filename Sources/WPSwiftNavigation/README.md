#  WPSwiftNavigation

A package on top of [swift-navigation](https://github.com/pointfreeco/swift-navigation) with support for more kinds of destinations.

## Supported Destinations

### Email Composer

```swift
struct EmailView: View {
  @Environment(\.canSendEmail) private var canSendEmail
  @State private var state: EmailComposerState?

  var body: some View {
    Group {
      if self.canSendEmail() {
        Button("Send Email") {
          self.state = EmailComposerState(subject: "My cool email!")
        }
      } else {
        Link(
          "Reach out to us on our support page!",
          destination: URL(string: "https://www.example.com/support")!
        )
      }
    }
    .emailComposer(self.$state) { result in
      switch result {
      case .sent:
        // ...
      case .saved:
        // ...
      case .cancelled:
        // ...
      case let .failed(error):
        // ...
      }
    }
  }
}
```
