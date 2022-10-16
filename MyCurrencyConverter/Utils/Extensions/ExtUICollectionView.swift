//
//  ExtUICollectionView.swift
//  MyCurrencyConverter
//
//  Created by MMU on 15.10.2022.
//

import UIKit

extension UICollectionView {
    func dequRCell(_ withIdentifier: String, _ indexPath: IndexPath) -> UICollectionViewCell {
        dequeueReusableCell(withReuseIdentifier: withIdentifier, for: indexPath)
    }
}
