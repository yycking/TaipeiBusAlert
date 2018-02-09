//
//  UserDefaults+.swift
//  TaipeiBusAlert
//
//  Created by Wayne Yeh on 2018/2/9.
//  Copyright © 2018年 Wayne Yeh. All rights reserved.
//

import Foundation


extension UserDefaults {
    open func set(_ jsonData: Data, forKey key: String) {
        guard let json = String(data: jsonData, encoding: String.Encoding.utf8) else {return}
        set(json, forKey: key)
    }
    
    open func data(forKey key: String) -> Data? {
        guard let string = value(forKey: key) as? String else {
            return nil
        }
        return string.data(using: .utf8)
    }
}
