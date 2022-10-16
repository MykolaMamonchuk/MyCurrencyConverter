//
//  ExtStoryboard.swift
//  MyCurrencyConverter
//
//  Created by MMU on 14.10.2022.
//

import UIKit

extension UIStoryboard {
    func initVC(_ identifier: String) -> UIViewController {
        return instantiateViewController(identifier: identifier)
    }
}
