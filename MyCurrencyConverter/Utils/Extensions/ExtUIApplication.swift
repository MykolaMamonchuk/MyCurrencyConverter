//
//  ExtUIApplication.swift
//  MyCurrencyConverter
//
//  Created by MMU on 16.10.2022.
//

import UIKit

extension UIApplication {
    var topViewController: UIViewController? {
        var topViewController: UIViewController?
        if #available(iOS 13, *) {
            topViewController = connectedScenes.compactMap {
                ($0 as? UIWindowScene)?.windows.filter { $0.isKeyWindow }.first?.rootViewController
            }.first
        } else {
            topViewController = keyWindow?.rootViewController
        }
        if let presented = topViewController?.presentedViewController {
            topViewController = presented
        } else if let navController = topViewController as? UINavigationController {
            topViewController = navController.topViewController
        } else if let tabBarController = topViewController as? UITabBarController {
            topViewController = tabBarController.selectedViewController
        }
        return topViewController
    }
}
