import Foundation

// MARK: - IPV4Address

/// An IPV4 Address.
public struct IPV4Address {
  private let interface: ifaddrs

  private init(interface: ifaddrs) {
    self.interface = interface
  }
}

// MARK: - Local Private IP

extension IPV4Address {
  /// The private IPV4 address assigned to this device on its local network if available.
  public static var localPrivate: Self? {
    var ifaddr: UnsafeMutablePointer<ifaddrs>?
    if getifaddrs(&ifaddr) == 0 {
      var _ptr = ifaddr
      while let ptr = _ptr {
        let isIPV4 = ptr.pointee.ifa_addr.pointee.sa_family == UInt8(AF_INET)
        let isWiFi = String(cString: ptr.pointee.ifa_name) == "en0"
        if isIPV4 && isWiFi {
          return Self(interface: ptr.pointee)
        }
        _ptr = ptr.pointee.ifa_next
      }
      freeifaddrs(ifaddr)
    }
    return nil
  }
}

// MARK: - CustomStringConvertible

extension IPV4Address: CustomStringConvertible {
  public var description: String {
    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
    getnameinfo(
      self.interface.ifa_addr,
      16,
      &hostname,
      socklen_t(hostname.count),
      nil,
      socklen_t(0),
      NI_NUMERICHOST
    )
    return String(cString: hostname, encoding: .utf8) ?? "Unknown Address"
  }
}
