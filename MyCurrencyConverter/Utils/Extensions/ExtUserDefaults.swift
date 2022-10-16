//
//  ExtUserDefaults.swift
//  MyCurrencyConverter
//
//  Created by MMU on 15.10.2022.
//

import Foundation

extension UserDefaults {
    func saveIntNSUDByKey(value: Int, key: String) {
        set(value, forKey: key)
        synchronize()
    }

    func getIntNSUDByKey(key: String, _ defaultReturn: Int? = nil) -> Int? {
        guard let obj = object(forKey: key) as? Int else { return defaultReturn }
        return obj
    }
}
