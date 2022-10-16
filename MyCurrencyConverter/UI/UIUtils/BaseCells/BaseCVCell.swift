//
//  BaseCVCell.swift
//  MyCurrencyConverter
//
//  Created by MMU on 15.10.2022.
//

import UIKit

class BaseCVCell: UICollectionViewCell {
    // MARK: - Class Methods

    class var className: String {
        return String(describing: self)
    }

    class var cellIdentifier: String {
        return String(describing: self)
    }

    class func register(_ aCollectionView: UICollectionView) {
        let nib = UINib(nibName: className, bundle: nil)
        aCollectionView.register(nib, forCellWithReuseIdentifier: cellIdentifier)
    }
}
