//
//  Commons.swift
//  MyCurrencyConverter
//
//  Created by MMU on 14.10.2022.
//

import Foundation
import UIKit

public enum UDKey {
    static let CountOpenedApp = "com.default.app.count.opened.app"
    static let CountConvertedTimes = "com.default.app.count.converted.times"
}

//  Storyboard constant
let kMainSB = UIStoryboard(name: "Main", bundle: nil)

enum ViewControllerIDs {
    enum MainSB {
        static let kMainConverterVC = "MainConverterVC"
        static let kDepositVC = "DepositVC"
    }
}
