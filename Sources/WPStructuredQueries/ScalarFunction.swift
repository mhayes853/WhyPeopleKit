import StructuredQueries

public struct ScalarFunction<QueryValue>: QueryExpression {
  let name: QueryFragment
  let arguments: [QueryFragment]

  public init<each Argument: QueryExpression>(
    _ name: QueryFragment,
    _ arguments: repeat each Argument
  ) {
    self.name = name
    var args = [QueryFragment]()
    for arg in repeat each arguments {
      args.append(arg.queryFragment)
    }
    self.arguments = args
  }

  public var queryFragment: QueryFragment {
    "\(name)(\(arguments.joined(separator: ", ")))"
  }
}
