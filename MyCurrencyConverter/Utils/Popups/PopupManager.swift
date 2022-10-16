//
//  PopupManager.swift
//  MyCurrencyConverter
//
//  Created by MMU on 14.10.2022.
//

import UIKit

let kPopupsSB = UIStoryboard(name: "Popups", bundle: nil)

enum ViewControllerPopupIDs {
    enum PopupsSB {
        static let kCurrencyListVC = "CurrencyListVC"
        static let kCustomAlertVC = "CustomAlertVC"
    }
}

class PopupManager {
    class func openCurrencyList(_ currentCurrency: String, _ completionBlock: @escaping StringOptBlock) {
        if let vc = kPopupsSB.instantiateViewController(withIdentifier: ViewControllerPopupIDs.PopupsSB.kCurrencyListVC) as? CurrencyListVC {
            vc.configureVC(currentCurrency, completionHandler: completionBlock)
            vc.modalPresentationStyle = .custom
            vc.modalTransitionStyle = .crossDissolve
            DispatchQueue.main.async {
                if let topVC = UIApplication.shared.topViewController {
                    topVC.present(vc, animated: true, completion: nil)
                }
            }
        }
    }

    class func openCustomAlert(_ title: String, _ desc: String, _ completionBlock: @escaping StringOptBlock) {
        if let vc = kPopupsSB.instantiateViewController(withIdentifier: ViewControllerPopupIDs.PopupsSB.kCustomAlertVC) as? CustomAlertVC {
            vc.configureVC(title, desc, completionHandler: completionBlock)
            vc.modalPresentationStyle = .custom
            vc.modalTransitionStyle = .crossDissolve
            DispatchQueue.main.async {
                if let topVC = UIApplication.shared.topViewController {
                    topVC.present(vc, animated: true, completion: nil)
                }
            }
        }
    }
}
