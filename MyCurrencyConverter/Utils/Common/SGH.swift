//
//  SGH.swift
//  MyCurrencyConverter
//
//  Created by MMU on 16.10.2022.
//

import NVActivityIndicatorView
public class SGH {
    public static let sI = SGH()
    public let activityIndicator = NVActivityIndicatorView(frame: UIScreen.main.bounds, type: .ballRotateChase, color: Colors.AccentM, padding: 100)

    public func startIndicator() {
        let topView = UIApplication.shared.topViewController?.navigationController?.view
        if topView == activityIndicator.superview { return }
        activityIndicator.backgroundColor = Colors.AccentM.withAlphaComponent(0.1)
        activityIndicator.startAnimating()
        topView?.addSubview(activityIndicator)
    }

    public func stopIndicator() {
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
    }
}
