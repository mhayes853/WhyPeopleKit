#if canImport(zlib)
  import zlib
  import Foundation

  extension Data {
    public func gzipped(
      level: GZipCompressionLevel = .defaultCompression
    ) throws(GZipError) -> Data {
      var new = self
      try new.gzip(level: level)
      return new
    }

    public mutating func gzip(
      level: GZipCompressionLevel = .defaultCompression
    ) throws(GZipError) {
      guard !self.isEmpty else { return }

      var stream = z_stream()
      stream.next_in = UnsafeMutablePointer<Bytef>(
        mutating: (self as NSData).bytes.bindMemory(to: Bytef.self, capacity: self.count)
      )
      stream.avail_in = uint(self.count)

      let memLevel = MAX_MEM_LEVEL
      let strategy = Z_DEFAULT_STRATEGY

      var status = deflateInit2_(
        &stream,
        level.rawValue,
        Z_DEFLATED,
        MAX_WBITS,
        memLevel,
        strategy,
        ZLIB_VERSION,
        Int32(MemoryLayout<z_stream>.size)
      )
      guard status == Z_OK else {
        throw GZipError(code: status)
      }

      var compressedData = Data(count: self.count / 2)
      repeat {
        if Int(stream.total_out) >= compressedData.count {
          compressedData.count += self.count / 2
        }
        let bufferPointer = compressedData.withUnsafeMutableBytes {
          $0.baseAddress?.assumingMemoryBound(to: Bytef.self)
        }
        guard let bufferPointer = bufferPointer else {
          throw GZipError(code: Z_BUF_ERROR)
        }
        stream.next_out = bufferPointer.advanced(by: Int(stream.total_out))
        stream.avail_out = uint(compressedData.count) - uint(stream.total_out)

        status = deflate(&stream, Z_FINISH)
      } while stream.avail_out == 0 && status == Z_OK

      guard status == Z_STREAM_END else {
        throw GZipError(code: status)
      }

      deflateEnd(&stream)
      compressedData.count = Int(stream.total_out)

      self = compressedData
    }
  }

  // MARK: - Compression Level

  extension Data {
    public struct GZipCompressionLevel: RawRepresentable, Sendable {
      public var rawValue: Int32

      public init(rawValue: Int32) {
        self.rawValue = rawValue
      }
    }
  }

  extension Data.GZipCompressionLevel {
    public static let bestSpeed = Self(rawValue: Z_BEST_SPEED)
    public static let bestCompression = Self(rawValue: Z_BEST_COMPRESSION)
    public static let noCompression = Self(rawValue: Z_NO_COMPRESSION)
    public static let defaultCompression = Self(rawValue: Z_DEFAULT_COMPRESSION)
  }

  // MARK: - Error

  extension Data {
    public struct GZipError: Error {
      public let code: Int32

      public init(code: Int32) {
        self.code = code
      }
    }
  }
#endif
