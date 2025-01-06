//import Testing
//import WPTCA

//@MainActor
//@Suite("ReferenceState tests")
//struct ReferenceStateTests {
//  @Test("No State Change When Reference Remains the Same")
//  func sameReference() async {
//    let store = TestStore(initialState: TestReducer.State()) {
//      TestReducer()
//    }
//    await store.send(.incremented)
//  }

//  @Test("Changes State When Reference Changes To New Reference")
//  func referenceChanged() async {
//    let store = TestStore(initialState: TestReducer.State()) {
//      TestReducer()
//    }
//    await store.send(.referenceChanged) {
//      $0.object = .newReference
//    }
//  }

//  @Test("Changes State When Existential State Increments")
//  func protoReferenceIncremented() async {
//    let store = TestStore(initialState: TestReducer.State()) {
//      TestReducer()
//    }
//    // NB: We cannot assert on the actual instance change because protoCounter is an existential,
//    // and not a strict reference type.
//    await withExpectedIssue { @Sendable in
//      await store.send(.protoIncremented)
//    }
//  }

//  @Test("Changes State When Existential State Changes Instance")
//  func protoReferenceChanged() async {
//    let store = TestStore(initialState: TestReducer.State()) {
//      TestReducer()
//    }
//    // NB: We cannot assert on the actual instance change because protoCounter is an existential,
//    // and not a strict reference type.
//    await withExpectedIssue { @Sendable in
//      await store.send(.protoReferenceChanged)
//    }
//  }
//}

//@Reducer
//private struct TestReducer {
//  @ObservableState
//  struct State: Equatable {
//    @ObservationStateIgnored
//    @ReferenceState var object = Counter()

//    @ObservationStateIgnored
//    @ReferenceState var protoCounter: any CounterProtocol = Counter()
//  }

//  enum Action {
//    case incremented
//    case referenceChanged
//    case protoIncremented
//    case protoReferenceChanged
//  }

//  var body: some ReducerOf<Self> {
//    Reduce { state, action in
//      switch action {
//      case .incremented:
//        state.object.count += 1
//        return .none

//      case .referenceChanged:
//        state.object = .newReference
//        return .none

//      case .protoIncremented:
//        state.protoCounter.count += 1
//        return .none

//      case .protoReferenceChanged:
//        state.protoCounter = Counter.newReference
//        return .none
//      }
//    }
//  }
//}

//private protocol CounterProtocol {
//  var count: Int { get set }
//}

//private final class Counter: CounterProtocol, @unchecked Sendable {
//  static let newReference = Counter()
//  var count = 0
//}
