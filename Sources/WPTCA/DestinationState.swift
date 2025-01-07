#if canImport(ComposableArchitecture)
  import ComposableArchitecture
  import SwiftUI

  // MARK: - Destination State

  public protocol DestinationState {
    associatedtype Destination: CasePathable
    var destination: Destination? { get set }
  }

  // MARK: - Destination Action

  public protocol DestinationAction {
    associatedtype _Action
    static func destination(_ action: PresentationAction<_Action>) -> Self
  }

  // MARK: - Is Presenting

  extension Perception.Bindable {
    public func isPresenting<
      State: DestinationState & ObservableState,
      Action: DestinationAction,
      Case
    >(
      _ casePath: CaseKeyPath<State.Destination, Case>
    ) -> Binding<Bool> where Value == Store<State, Action> {
      self[isPresenting: casePath]
    }
  }

  @available(iOS 17, macOS 14, tvOS 17, watchOS 10, *)
  extension SwiftUI.Bindable {
    @MainActor
    public func isPresenting<
      State: DestinationState & ObservableState,
      Action: DestinationAction,
      Case
    >(
      _ casePath: CaseKeyPath<State.Destination, Case>
    ) -> Binding<Bool> where Value == Store<State, Action> {
      self[isPresenting: casePath]
    }
  }

  extension Store where State: DestinationState & ObservableState, Action: DestinationAction {
    fileprivate subscript<Case>(
      isPresenting casePath: CaseKeyPath<State.Destination, Case>
    ) -> Bool {
      get { self.destination?.is(casePath) ?? false }
      set {
        guard !newValue else { return }
        self.send(.destination(.dismiss))
      }
    }
  }
#endif
