import Foundation

// MARK: - IPV4Address

/// An IPV4 Address.
public struct IPV4Address {
  private let addr: sockaddr
}

// MARK: - For Interface Name

extension IPV4Address {
  /// Attempts to create an IP Address from a specified interface name.
  ///
  /// - Parameter interfaceName: The name of the network interface.
  public init?(interfaceName: String) {
    var ifaddr: UnsafeMutablePointer<ifaddrs>?
    if getifaddrs(&ifaddr) == 0 {
      defer { freeifaddrs(ifaddr) }
      var _ptr = ifaddr
      while let ptr = _ptr {
        let isIPV4 = ptr.pointee.ifa_addr.pointee.sa_family == UInt8(AF_INET)
        let isInterface = String(cString: ptr.pointee.ifa_name) == interfaceName
        if isIPV4 && isInterface {
          var addr = sockaddr()
          memcpy(&addr, ptr.pointee.ifa_addr, MemoryLayout<sockaddr>.size)
          self.init(addr: addr)
          return
        }
        _ptr = ptr.pointee.ifa_next
      }
    }
    return nil
  }
}

// MARK: - Local Private IP

extension IPV4Address {
  /// The private IPV4 address assigned to this device on its local network if available.
  public static var localPrivate: Self? {
    Self(interfaceName: "en0")
  }
}

// MARK: - CustomStringConvertible

extension IPV4Address: CustomStringConvertible {
  public var description: String {
    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
    var addr = self.addr
    getnameinfo(
      &addr,
      UInt32(MemoryLayout<sockaddr>.size),
      &hostname,
      socklen_t(hostname.count),
      nil,
      socklen_t(0),
      NI_NUMERICHOST
    )
    return String(cString: hostname, encoding: .utf8) ?? "Unknown Address"
  }
}
