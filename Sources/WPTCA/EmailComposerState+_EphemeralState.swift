//#if canImport(ComposableArchitecture)
//  import ComposableArchitecture
//  import SwiftUI
//  import WPSwiftNavigation

//  // MARK: - EmailComposerState Conformance

//  public typealias EmailComposerAction = EmailComposerResult

//  extension EmailComposerState: _EphemeralState {
//    public typealias Action = EmailComposerAction
//  }

//  // MARK: - View Modifier

//  extension View {
//    @available(watchOS, unavailable)
//    @available(macOS, unavailable)
//    @available(tvOS, unavailable)
//    public func emailComposer(
//      store: Binding<Store<EmailComposerState, EmailComposerAction>?>
//    ) -> some View {
//      self.modifier(ComposableEmailComposerModifier(store: store))
//    }
//  }

//  @available(watchOS, unavailable)
//  @available(macOS, unavailable)
//  @available(tvOS, unavailable)
//  private struct ComposableEmailComposerModifier: ViewModifier {
//    @Binding var store: Store<EmailComposerState, EmailComposerAction>?

//    func body(content: Content) -> some View {
//      Group {
//        if let store {
//          content.emailComposer(.constant(store.withState { $0 })) { result in
//            store.send(result)
//          } onDismiss: {
//            self.store = nil
//          }
//        } else {
//          content
//        }
//      }
//    }
//  }
//#endif
