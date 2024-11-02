#  WPTestSupport

A collection of utilities for automated testing.

## Overview

Ensure that this package is only linked to a unit/swift package test target, as Xcode will not be able to build your actual application code due to XCTest and Swift Testing imports.

### Timed Confirmations

Swift Testing ships with a `confirmation` API that is supposed to be the equivalent of `XCTestExpectation` in XCTest. However, it does not mimic all of what `XCTestExpecation` can do. For instance, let's look at this code:

```swift
@Test("Food Truck Bakes N Times")
func bakes() async {
  let n = 10
  await confirmation("Baked buns", expectedCount: n) { bunBaked in
    // Event handler is invoked asynchronously by bakeAsync
    foodTruck.eventHandler = { event in
      if event == .baked(.cinnamonBun) {
        bunBaked()
      }
    }
    foodTruck.bakeAsync(.cinnamonBun, count: n)
  }
}
```

This test will always fail, because `confirmation` will only wait until the body closure is finished executing before deciding to raise an issue.

In XCTest, we can wait for the fullfillment of an `XCTestExpectation` with a timeout. This allows us to write a test for the above code like so:

```swift
final class FoodTruckTests: XCTestCase {
  func testBakes() async {
    let n = 10
    let expectation = self.expectation("Bakes n times")
    expectation.expectedFulfillmentCount = n
    foodTruck.eventHandler = { event in
      if event == .baked(.cinnamonBun) {
        expectation.fulfill()
      }
    }
    foodTruck.bakeAsync(.cinnamonBun, count: n)
    await self.fullfillment(of: [expectation], timeout: 1) // Timeout after 1 second
  }
}
```

This test passes because we explicitly await for the expectation to be fulfilled. If more than 1 second passes, then the test will fail.

Using `timedConfirmation`, you can achieve the same behavior as the XCTest version.

```swift
@Test("Food Truck Bakes N Times")
func bakes() async {
  let n = 10
  await timedConfirmation("Baked buns", expectedCount: n, timeout: .seconds(1)) { bunBaked in
    // Event handler is invoked asynchronously by bakeAsync
    foodTruck.eventHandler = { event in
      if event == .baked(.cinnamonBun) {
        bunBaked()
      }
    }
    foodTruck.bakeAsync(.cinnamonBun, count: n)
  }
}
```

This will either wait 1 second for the timeout to expire (which fails the test), or will wait for the confirmation to be confirmed n times (which passes the test). Therefore, it behaves exactly like the XCTest version.
