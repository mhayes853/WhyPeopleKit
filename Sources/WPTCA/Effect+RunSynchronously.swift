//#if canImport(ComposableArchitecture)
//  import Combine
//  import ComposableArchitecture

//  extension Effect {
//    /// An ``Effect`` that runs synchronously without starting up a task.
//    public static func runSynchronously(
//      _ work: @escaping () -> Void
//    ) -> Effect<Action> {
//      .publisher {
//        work()
//        return Empty<Action, Never>(completeImmediately: true)
//      }
//    }

//    /// An ``Effect`` that runs synchronously without starting up a task.
//    public static func runSynchronously(
//      _ work: @escaping () -> Action
//    ) -> Effect<Action> {
//      .publisher { Just(work()) }
//    }
//  }
//#endif
