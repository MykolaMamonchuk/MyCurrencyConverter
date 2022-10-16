//
//  DepositVC.swift
//  MyCurrencyConverter
//
//  Created by MMU on 14.10.2022.
//

import UIKit

class DepositVC: UIViewController {
    // MARK: USER IBOutlets (If needed)

    // MARK: -

    @IBOutlet var depositTF: UITextField!
    @IBOutlet var currencyBTN: UIButton!
    @IBOutlet var addBTN: UIButton!
    @IBOutlet var addButtonBottomConstraint: NSLayoutConstraint!

    // MARK: -

    // MARK: Public variable

    // MARK: -

    // MARK: -

    // MARK: Private variable

    // MARK: -

    // MARK: -

    // MARK: View Lifecycle (If needed)

    // MARK: -

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()

        let NCD = NotificationCenter.default
        NCD.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NCD.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    private func configureUI() {
        navigationSettings()

        depositTF.becomeFirstResponder()
    }

    private func navigationSettings() {
        defaultColorNavBar()

        let backBtn = UIBarButtonItem(
            image: UIImage(named: "icnArrowLeft"),
            style: .plain,
            target: self,
            action: #selector(navigationBackAction(_:))
        )

        navigationItem.setLeftBarButton(backBtn, animated: true)
        navigationItem.title = "Deposit to an account"
    }

    @objc func navigationBackAction(_: Any?) {
        navigationController?.popViewController(animated: true)
    }

    // MARK: -

    // MARK: USER IBActions (If needed)

    // MARK: -

    @IBAction func onBtnChooseCurrencyAction(_: UIButton?) {
        view.endEditing(true)
        let currentCurrency = currencyBTN.titleLabel?.text ?? "USD"
        PopupManager.openCurrencyList(currentCurrency) { [weak self] response in
            if let chosenCurrency = response {
                self?.currencyBTN.setTitle(chosenCurrency, for: .normal)
            }
        }
    }

    @IBAction func onBtnAddDepositAction(_: UIButton?) {
        guard let currency = currencyBTN.titleLabel?.text else { return }
        guard let balance = depositTF.text?.floatValue else { return }
        let balanceCents = Int(balance * 100)

        if balanceCents > 0 {
            UserAccount.sI.addDeposide(currency: currency, totalDepositSumm: balanceCents)

            UserAccount.sI.loadCurrencyRate(sellCurrency: currency, buyCurrency: nil) { [weak self] _ in
                self?.navigationBackAction(nil)
            }

        } else {
            PopupManager.openCustomAlert("Error", "Deposit can't be zero") { _ in }
        }
    }

    // MARK: -

    // MARK: ADDITIONAL PUBLIC HELPERS

    // MARK: -

    @objc func keyboardWillShow(_ notification: NSNotification) {
        if let keyboard = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            addButtonBottomConstraint.constant = keyboard.height + 12
        }
    }

    @objc func keyboardWillHide(_: NSNotification) {
        addButtonBottomConstraint.constant = 20
    }
}

extension DepositVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == depositTF, let currentText = textField.text, let newRange = Range(range, in: currentText) {
            guard let newString = textField.text?.replacingCharacters(in: newRange, with: string) else { return false }

            let totalPart = newString.components(separatedBy: ".")
            if (totalPart.count >= 2 && (totalPart.last?.count ?? 0) > 2) || totalPart.count > 2 {
                return false
            }

            if newString.intValue > maxDeposit { return false }
            textField.text = newString
            addBTN.isEnabled = (textField.text?.intValue ?? 0) > 0

            return false
        }
        return true
    }
}
