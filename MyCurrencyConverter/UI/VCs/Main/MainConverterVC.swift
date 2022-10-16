//
//  MainConverterVC.swift
//  MyCurrencyConverter
//
//  Created by MMU on 14.10.2022.
//

import UIKit

class MainConverterVC: UIViewController {
    // MARK: USER IBOutlets (If needed)

    // MARK: -

    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var sellBalanceTF: UITextField!
    @IBOutlet var sellCurrencyBTN: UIButton!

    @IBOutlet var commissionFeeLBL: UILabel!
    @IBOutlet var buyBalanceLBL: UILabel!
    @IBOutlet var buyCurrencyBTN: UIButton!

    @IBOutlet var convertBTN: UIButton!
    @IBOutlet var convertBtnBottomConstraint: NSLayoutConstraint!

    @IBOutlet var emptyContainerView: UIView!

    // MARK: -

    // MARK: Public variable

    // MARK: -

    // MARK: -

    // MARK: Private variable

    // MARK: -

    private var convertSettings = (sell: "", buy: "") {
        didSet {
            buyCurrencyBTN.setTitle(convertSettings.buy, for: .normal)
            sellCurrencyBTN.setTitle(convertSettings.sell, for: .normal)
            clearDepositInputs()
        }
    }

    // MARK: -

    // MARK: View Lifecycle (If needed)

    // MARK: -

    override func viewDidLoad() {
        super.viewDidLoad()

        prepareUserContent()
        configureUI()

        let NCD = NotificationCenter.default
        NCD.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NCD.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NCD.addObserver(self, selector: #selector(didChangeDeposit(_:)), name: .SELDidChangeDeposit, object: nil)
    }

    private func configureUI() {
        navigationSettings()
        configurCells()
    }

    private func navigationSettings() {
        defaultColorNavBar()

        navigationController?.navigationItem.hidesBackButton = true
        let depositNavBtn = UIBarButtonItem(
            image: UIImage(named: "icnDeposit"),
            style: .plain,
            target: self,
            action: #selector(openDepositScreenAction(_:))
        )

        navigationItem.setRightBarButton(depositNavBtn, animated: true)
        navigationItem.title = "Currency converter"
    }

    // MARK: -

    // MARK: USER IBActions (If needed)

    // MARK: -

    @IBAction func openDepositScreenAction(_: Any?) {
        if let vc = kMainSB.initVC(ViewControllerIDs.MainSB.kDepositVC) as? DepositVC {
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    @IBAction func onBtnChooseCurrencyAction(_ sender: UIButton?) {
        view.endEditing(true)

        guard let currentCurrency = sender?.titleLabel?.text else {
            PopupManager.openCustomAlert("Error", "Unknown currency symbol") { _ in }
            return
        }

        PopupManager.openCurrencyList(currentCurrency) { [weak self] response in
            if let chosenCurrency = response {
                if sender == self?.sellCurrencyBTN, chosenCurrency != currentCurrency {
                    self?.convertSettings.sell = chosenCurrency
                    self?.convertSettings.buy = currentCurrency
                } else if sender == self?.sellCurrencyBTN {
                    self?.convertSettings.sell = chosenCurrency
                } else {
                    self?.convertSettings.buy = chosenCurrency
                }

                self?.updateCurrencyRate()
            }
        }
    }

    @IBAction func onBtnConvertAction(_: UIButton?) {
        view.endEditing(true)

        guard let depoSumm = sellBalanceTF.text else { return }
        if depoSumm.floatValue <= 0.0 {
            PopupManager.openCustomAlert("Error", "Sum must be more") { _ in }
            return
        }
        switch UserAccount.sI.isConvertBalance(convertSettings.sell, depoSumm) {
        case .noBalance, .unknown:
            PopupManager.openCustomAlert("Error", "Lack of money in your account") { _ in }
        case .granded:

            SGH.sI.startIndicator()
            let commission = UserAccount.sI.hasCommission(depoSumm)
            UserAccount.sI.convert(
                sellCurrency: convertSettings.sell,
                buyCurrency: convertSettings.buy,
                depoSumm: depoSumm
            ) { [weak self] responseModel in
                self?.clearDepositInputs()

                if let model = responseModel as? ConvertML {
                    let sellTxt = depoSumm + " " + (self?.convertSettings.sell ?? "Unkonwn")
                    let buyTxt = (model.amount ?? "0.00") + " " + (self?.convertSettings.buy ?? "Unkonwn")
                    let fee = Float(commission.feeSumm) / 100.0

                    let commTxt = commission.fee > 0.0 ? " Commission Fee - \(fee) \(self?.convertSettings.sell ?? "Unkonwn")." : ""

                    PopupManager.openCustomAlert(
                        "Currency converted",
                        "You have converted \(sellTxt) to \(buyTxt).\(commTxt)"
                    ) { _ in }
                }
                SGH.sI.stopIndicator()
            }
        }
    }

    // MARK: -

    // MARK: ADDITIONAL PUBLIC HELPERS

    // MARK: -

    @objc func keyboardWillShow(_ notification: NSNotification) {
        if let keyboard = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            convertBtnBottomConstraint.constant = keyboard.height + 4
        }
    }

    @objc func keyboardWillHide(_: NSNotification) {
        convertBtnBottomConstraint.constant = 20
    }

    @objc func didChangeDeposit(_: NSNotification) {
        if convertSettings.sell.isEmpty {
            prepareUserContent()
        } else {
            collectionView.reloadData()
        }
    }

    func prepareUserContent() {
        SGH.sI.startIndicator()
        UserAccount.sI.prepareData { [weak self] _ in
            if let availableCurrency = UserAccount.sI.currencyRate.keys.first?.components(separatedBy: "-"), availableCurrency.count >= 2 {
                self?.convertSettings = (sell: availableCurrency.first ?? "UNKNOWN", buy: availableCurrency.last ?? "UNKNOWN")
            }
            self?.emptyContainerView.isHidden = !UserAccount.sI.userDepositList.isEmpty
            self?.collectionView.reloadData()
            SGH.sI.stopIndicator()
        }
    }

    func clearDepositInputs() {
        sellBalanceTF.text = nil
        buyBalanceLBL.text = "0.00"
        convertBTN.isEnabled = false
        commissionFeeLBL.isHidden = true
    }

    // MARK: -

    // MARK: ADDITIONAL PRIVATE HELPERS

    // MARK: -

    private func configurCells() {
        collectionView.automaticallyAdjustsScrollIndicatorInsets = false
        UserDepositCCell.register(collectionView)
        collectionView.reloadData()
    }

    private func updateCurrencyRate() {
        SGH.sI.startIndicator()
        view.endEditing(true)
        UserAccount.sI.loadCurrencyRate(sellCurrency: convertSettings.sell, buyCurrency: convertSettings.buy) { _ in
            SGH.sI.stopIndicator()
        }
    }
}

extension MainConverterVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        UserAccount.sI.userDepositList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequRCell(UserDepositCCell.cellIdentifier, indexPath) as? UserDepositCCell else { fatalError() }

        cell.configure(UserAccount.sI.userDepositList[indexPath.row])
        return cell
    }
}

extension MainConverterVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let sellCyrrency = sellCurrencyBTN.titleLabel?.text

        if textField == sellBalanceTF, let currentText = textField.text, let newRange = Range(range, in: currentText) {
            guard let newString = textField.text?.replacingCharacters(in: newRange, with: string) else { return false }
            if UserAccount.sI.isConvertBalance(sellCyrrency, newString) != .granded {
                let commission = UserAccount.sI.hasCommission(newString)
                if commission.fee > 0.0 {
                    let convertSum = newString
                    let sumWithFee = Float(UserAccount.sI.getSumWithFee(newString)) / 100.0

                    PopupManager.openCustomAlert("Error", "Lack of money in your account.\nYou want to convert \(convertSum) \(convertSettings.sell)\n + commission fee of \(commission.fee)%. In total, you need \(sumWithFee) \(convertSettings.sell)") { _ in }
                } else {
                    PopupManager.openCustomAlert("Error", "Lack of money in your account.\nYou want to convert \(newString)") { _ in }
                }

                return false
            }

            if newString.intValue > maxDeposit { return false }

            let totalPart = newString.components(separatedBy: ".")
            if (totalPart.count >= 2 && (totalPart.last?.count ?? 0) > 2) || totalPart.count > 2 {
                return false
            }

            textField.text = newString
            let buyCyrrency = buyCurrencyBTN.titleLabel?.text
            let convertBalance = textField.text?.floatValue ?? 0.0
            convertBTN.isEnabled = convertBalance > 0.0

            let commission = UserAccount.sI.hasCommission(newString)
            commissionFeeLBL.isHidden = commission.fee <= 0.0 || newString.isEmpty || newString.intValue <= 0
            commissionFeeLBL.text = "Commission Fee \(commission.fee)%: \(Float(commission.feeSumm) / 100.0) \(convertSettings.sell)"
            buyBalanceLBL.text = UserAccount.sI.predictConvertedBalance(sellCyrrency, buyCyrrency, convertBalance)

            return false
        }
        return true
    }
}
