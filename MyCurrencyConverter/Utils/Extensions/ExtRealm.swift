//
//  ExtRealm.swift
//  MyCurrencyConverter
//
//  Created by MMU on 14.10.2022.
//

import RealmSwift

extension Results {
    func toArray() -> [Element] {
        return compactMap { $0 }
    }
}
