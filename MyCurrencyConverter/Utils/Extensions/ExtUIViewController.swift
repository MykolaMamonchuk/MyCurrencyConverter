//
//  ExtUIViewController.swift
//  MyCurrencyConverter
//
//  Created by MMU on 14.10.2022.
//

import UIKit

extension UIViewController {
    public func clearNavStyle() {
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: Colors.Title3, .font: UIFont.systemFont(ofSize: 17, weight: .bold)]

        navigationController?.navigationBar.tintColor = .black // Button Color
        navigationController?.navigationBar.barTintColor = Colors.AccentM // Main Background View
        defaultNavData()
    }

    func defaultColorNavBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = Colors.AccentM
        appearance.titleTextAttributes = [.foregroundColor: Colors.Title3, .font: UIFont.systemFont(ofSize: 17, weight: .bold)]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = navigationController?.navigationBar.standardAppearance
        navigationController?.navigationBar.tintColor = Colors.Title3 // Button Color

        defaultNavData()
    }

    func defaultNavData() {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
}
