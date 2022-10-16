//
//  CustomAlertVC.swift
//  MyCurrencyConverter
//
//  Created by MMU on 15.10.2022.
//

import UIKit

class CustomAlertVC: UIViewController {
    // MARK: - Private variables

    private var titleModal: String?
    private var descModal: String?
    private var completionBlock: StringOptBlock!

    @IBOutlet var titleLBL: UILabel!
    @IBOutlet var descLBL: UILabel!

    // MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        titleLBL.text = titleModal
        descLBL.text = descModal
    }

    // MARK: - Public methods

    func configureVC(_ title: String, _ desc: String, completionHandler: @escaping StringOptBlock) {
        completionBlock = completionHandler
        titleModal = title
        descModal = desc
    }

    // MARK: - IBActions

    @IBAction func cancelAction(_: Any) {
        dismiss(animated: true) { [weak self] in self?.completionBlock(nil) }
    }

    override func touchesBegan(_: Set<UITouch>, with _: UIEvent?) {
        dismiss(animated: true) { [weak self] in self?.completionBlock(nil) }
    }
}
