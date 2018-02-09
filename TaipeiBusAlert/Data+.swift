//
//  Data+.swift
//  TaipeiBusAlert
//
//  Created by Wayne Yeh on 2018/2/9.
//  Copyright © 2018年 Wayne Yeh. All rights reserved.
//

import Foundation
import zlib

extension Data {
    
    private func createZStream() -> z_stream {
        
        var stream = z_stream()
        
        self.withUnsafeBytes { (bytes: UnsafePointer<Bytef>) in
            stream.next_in = UnsafeMutablePointer<Bytef>(mutating: bytes)
        }
        stream.avail_in = uint(self.count)
        
        return stream
    }
    
    public func gunzipped() -> Data? {
        
        guard !self.isEmpty else {
            return Data()
        }
        
        let contiguousData = self.withUnsafeBytes { Data(bytes: $0, count: self.count) }
        var stream = contiguousData.createZStream()
        var status: Int32
        
        status = inflateInit2_(&stream, MAX_WBITS + 32, ZLIB_VERSION, Int32(MemoryLayout<z_stream>.size))
        
        guard status == Z_OK else {
            return nil
        }
        
        var data = Data(capacity: contiguousData.count * 2)
        
        repeat {
            if Int(stream.total_out) >= data.count {
                data.count += contiguousData.count / 2
            }
            
            data.withUnsafeMutableBytes { (bytes: UnsafeMutablePointer<Bytef>) in
                stream.next_out = bytes.advanced(by: Int(stream.total_out))
            }
            stream.avail_out = uInt(data.count) - uInt(stream.total_out)
            
            status = inflate(&stream, Z_SYNC_FLUSH)
            
        } while status == Z_OK
        
        guard inflateEnd(&stream) == Z_OK && status == Z_STREAM_END else {
            
            return nil
        }
        
        data.count = Int(stream.total_out)
        
        return data
    }
}
