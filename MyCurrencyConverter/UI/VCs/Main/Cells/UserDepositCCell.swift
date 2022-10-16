//
//  UserDepositCCell.swift
//  MyCurrencyConverter
//
//  Created by MMU on 15.10.2022.
//

import UIKit

class UserDepositCCell: BaseCVCell {
    // MARK: IBOurtlets

    @IBOutlet var balanceLBL: UILabel!

    // MARK: Initialization

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    // MARK: Public methods

    func configure(_ model: DepositML) {
        guard let currency = model.currency else { return }
        balanceLBL.text = UserAccount.sI.getFormattedBalance(model.balance) + " " + currency
    }
}
