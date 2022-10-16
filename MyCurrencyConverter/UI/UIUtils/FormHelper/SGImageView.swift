//
//  SGImageView.swift
//  MyCurrencyConverter
//
//  Created by MMU on 15.10.2022.
//

import UIKit

class SGImageView: UIImageView {
    // MARK: IBInspectables

    @IBInspectable var brdRadiusByHeight: Bool = false

    @IBInspectable var brdRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = brdRadius
            clipsToBounds = true
        }
    }

    @IBInspectable var brdWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = brdWidth
        }
    }

    @IBInspectable var brdColor: UIColor? {
        didSet {
            layer.borderColor = brdColor?.cgColor
        }
    }

    // MARK: Private properties

    private var oldFrame = CGRect.zero

    // MARK: Initializations

    override func layoutSubviews() {
        super.layoutSubviews()

        if !frame.equalTo(oldFrame) {
            SELAddComponents()
            oldFrame = frame
        }
    }

    // MARK: Private methods

    private func SELAddComponents() {
        if brdRadiusByHeight {
            layer.cornerRadius = frame.height / 2.0
            clipsToBounds = true
        }
    }
}
