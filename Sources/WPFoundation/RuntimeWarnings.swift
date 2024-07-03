// The following file is extracted from `swift-composable-architecture`
// https://github.com/pointfreeco/swift-composable-architecture
//
// MIT License
//
// Copyright (c) 2020 Point-Free, Inc.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
import Foundation
import os

/// Emits a purple runtime warning in Xcode.
@_transparent
@inline(__always)
public func runtimeWarn(
  _ message: @autoclosure () -> String,
  category: String? = "WPFoundation",
  file: StaticString? = nil,
  line: UInt? = nil
) {
#if DEBUG
  let message = message()
  if _canFailCurrentTest {
    if let file, let line {
      failCurrentTest(message, file: file, line: line)
    } else {
      failCurrentTest(message)
    }
  } else {
    _runtimeWarn(message, category: category, file: file, line: line)
  }
#endif
}

public func _runtimeWarn(
  _ message: @autoclosure () -> String,
  category: String? = "WPFoundation",
  file: StaticString? = nil,
  line: UInt? = nil
) {
#if DEBUG
  let message = message()
  let category = category ?? "Runtime Warning"
  os_log(
    .fault,
    dso: dso,
    log: OSLog(subsystem: "com.apple.runtime-issues", category: category),
    "%@",
    message
  )
#endif
}

#if DEBUG
// NB: Xcode runtime warnings offer a much better experience than traditional assertions and
//     breakpoints, but Apple provides no means of creating custom runtime warnings ourselves.
//     To work around this, we hook into SwiftUI's runtime issue delivery mechanism, instead.
//
// Feedback filed: https://gist.github.com/stephencelis/a8d06383ed6ccde3e5ef5d1b3ad52bbc
@usableFromInline
nonisolated(unsafe) let dso = { () -> UnsafeRawPointer in
  let count = _dyld_image_count()
  for i in 0..<count {
    if let name = _dyld_get_image_name(i) {
      let swiftString = String(cString: name)
      if swiftString.hasSuffix("/SwiftUI") {
        if let header = _dyld_get_image_header(i) {
          return UnsafeRawPointer(header)
        }
      }
    }
  }
  return #dsohandle
}()
#endif
