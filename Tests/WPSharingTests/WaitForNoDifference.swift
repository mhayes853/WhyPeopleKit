func waitForNoDifference<T: Equatable & Sendable>(
  _ value: @autoclosure @MainActor () -> T,
  _ expectedValue: @autoclosure @MainActor () -> T
) async {
  repeat {
    let values = await (value(), expectedValue())
    if values.0 == values.1 {
      break
    }
    await Task.yield()
  } while true
}
