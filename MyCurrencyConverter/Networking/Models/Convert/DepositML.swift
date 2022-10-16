//
//  DepositML.swift
//  MyCurrencyConverter
//
//  Created by MMU on 15.10.2022.
//

import RealmSwift

final class DepositML: Object {
    @Persisted var currency: String?
    @Persisted var balance: Int?

    convenience init(currency curr: String, totalDepositSumm summ: Int) {
        self.init()
        currency = curr
        balance = summ
    }
}
