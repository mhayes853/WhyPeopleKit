#if canImport(ComposableArchitecture)
  import WPSharing
  import ComposableArchitecture

  extension Reducer {
    @warn_unqualified_access
    public func forEach<
      ElementState,
      ElementAction,
      ID: Hashable,
      Element: Reducer<ElementState, ElementAction>
    >(
      _ toElementsState: WritableKeyPath<State, DerivedArray<ID, ElementState>>,
      action toElementAction: CaseKeyPath<Action, IdentifiedAction<ID, ElementAction>>,
      @ReducerBuilder<ElementState, ElementAction> element: () -> Element,
      fileID: StaticString = #fileID,
      filePath: StaticString = #filePath,
      line: UInt = #line,
      column: UInt = #column
    ) -> some Reducer<State, Action> {
      self.forEach(
        toElementsState.appending(path: \.identifiedArray),
        action: toElementAction,
        element: element,
        fileID: fileID,
        filePath: filePath,
        line: line,
        column: column
      )
    }
  }
#endif
