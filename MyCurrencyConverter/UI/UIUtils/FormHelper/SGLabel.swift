//
//  SGLabel.swift
//  MyCurrencyConverter
//
//  Created by MMU on 15.10.2022.
//

import UIKit

class SGLabel: UILabel {
    // MARK: IBInspectables

    @IBInspectable var edgeProportional: Bool = false
    @IBInspectable var edgeProporcialContainerHeight: CGFloat = 0
    @IBInspectable var edgeProporcialContainerWidth: CGFloat = 0
    @IBInspectable var edgeT: CGFloat = 0 {
        didSet {
            edgeT = edgeProportional ? getProportionHeight(edgeT, frame.height, edgeProporcialContainerHeight) : edgeT
        }
    }

    @IBInspectable var edgeR: CGFloat = 0 {
        didSet { edgeR = edgeProportional ? getProportionHeight(edgeR, frame.width, edgeProporcialContainerWidth) : edgeR }
    }

    @IBInspectable var edgeB: CGFloat = 0 {
        didSet { edgeB = edgeProportional ? getProportionHeight(edgeB, frame.height, edgeProporcialContainerHeight) : edgeB }
    }

    @IBInspectable var edgeL: CGFloat = 0 {
        didSet { edgeL = edgeProportional ? getProportionHeight(edgeL, frame.width, edgeProporcialContainerWidth) : edgeL }
    }

    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        if edgeT != 0 || edgeR != 0 || edgeB != 0 || edgeL != 0 {
            let inset = UIEdgeInsets(top: edgeT, left: edgeL, bottom: edgeB, right: edgeR)
            var rect = super.textRect(forBounds: bounds, limitedToNumberOfLines: numberOfLines)
            rect.origin.x -= inset.left
            rect.origin.y -= inset.top
            rect.size.width += (inset.left + inset.right)
            rect.size.height += (inset.top + inset.bottom)
            return rect
        } else {
            return super.textRect(forBounds: bounds, limitedToNumberOfLines: numberOfLines)
        }
    }

    // MARK: Initializations

    override func drawText(in rect: CGRect) {
        if edgeT != 0 || edgeR != 0 || edgeB != 0 || edgeL != 0 {
            super.drawText(in: rect.inset(by: UIEdgeInsets(top: edgeT, left: edgeL, bottom: edgeB, right: edgeR)))
        } else {
            super.drawText(in: rect)
        }
    }

    // MARK: Private methods

    private func getProportionHeight(_ height: CGFloat, _ byHeight: CGFloat = 667, _ containerHeight: CGFloat = UIScreen.main.bounds.height) -> CGFloat {
        return height * (containerHeight / byHeight)
    }
}
