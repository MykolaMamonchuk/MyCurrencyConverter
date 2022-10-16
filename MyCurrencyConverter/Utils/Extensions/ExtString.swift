//
//  ExtString.swift
//  MyCurrencyConverter
//
//  Created by MMU on 14.10.2022.
//

import Foundation

extension String {
    var floatValue: Float {
        return (self as NSString).floatValue
    }

    var intValue: Int {
        return (self as NSString).integerValue
    }
}
