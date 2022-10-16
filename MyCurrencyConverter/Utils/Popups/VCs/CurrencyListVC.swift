//
//  CurrencyListVC.swift
//  MyCurrencyConverter
//
//  Created by MMU on 14.10.2022.
//

import UIKit

class CurrencyListVC: UIViewController {
    // MARK: - Private variables

    private var listData: [DataPickerML] = .init()
    private var titleModal: String?
    private var completionBlock: StringOptBlock!
    private var currentCurrency: String?

    @IBOutlet var titleLBL: UILabel!
    @IBOutlet var pickerView: UIPickerView!

    // MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        titleLBL.text = titleModal

        if let currentIndex = listData.firstIndex(where: { ($0.data as? String) == currentCurrency }) {
            pickerView.selectRow(currentIndex, inComponent: 0, animated: true)
        }
    }

    // MARK: - Public methods

    func configureVC(_ currentCurrency: String, completionHandler: @escaping StringOptBlock) {
        completionBlock = completionHandler
        self.currentCurrency = currentCurrency
        titleModal = "Choose currency"

        currencyList.forEach {
            listData.append(DataPickerML(title: $0, data: $0))
        }
    }

    // MARK: - IBActions

    @IBAction func selectedAction(_: Any) {
        let currentIndex = pickerView.selectedRow(inComponent: 0)
        if currentIndex < listData.count {
            dismiss(animated: true) { [weak self] in
                let currency = self?.listData[currentIndex].data as? String
                self?.completionBlock(currency)
            }
        }
        print(currentIndex)
    }

    @IBAction func cancelAction(_: Any) {
        dismiss(animated: true) { [weak self] in self?.completionBlock(nil) }
    }

    override func touchesBegan(_: Set<UITouch>, with _: UIEvent?) {
        dismiss(animated: true) { [weak self] in self?.completionBlock(nil) }
    }
}

extension CurrencyListVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in _: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_: UIPickerView, numberOfRowsInComponent _: Int) -> Int {
        return listData.count
    }

    func pickerView(_: UIPickerView, titleForRow row: Int, forComponent _: Int) -> String? {
        return listData[row].title
    }
}

class DataPickerML {
    let UMI: String = UUID().uuidString // Unique model identification
    let title: String
    let data: Any?
    let dataObj: String?

    init(title: String, data: Any) {
        self.title = title
        self.data = data
        dataObj = "\(data)"
    }

    static func == (lhs: DataPickerML, rhs: DataPickerML) -> Bool {
        return lhs.UMI == rhs.UMI
    }
}
