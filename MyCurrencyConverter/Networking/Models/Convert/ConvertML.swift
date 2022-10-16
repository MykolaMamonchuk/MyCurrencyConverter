//
//  ConvertML.swift
//  MyCurrencyConverter
//
//  Created by MMU on 14.10.2022.
//

import Foundation

class ConvertML: Codable {
    var amount: String?
    var currency: String?

    enum CodingKeys: String, CodingKey {
        case amount, currency
    }
}
