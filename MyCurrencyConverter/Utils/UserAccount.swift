//
//  UserAccount.swift
//  MyCurrencyConverter
//
//  Created by MMU on 14.10.2022.
//

import Alamofire
import Foundation
import RealmSwift

final class UserAccount {
    enum UserAccountConvertStatus {
        case unknown, granded, noBalance
    }

    // MARK: -

    // MARK: Initialization

    // MARK: -

    init() {
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        formatter.positiveFormat = "###,###,###,###.##"

        getDeposideList()
    }

    // MARK: -

    // MARK: Public properies

    // MARK: -

    public static let sI = UserAccount()
    public var userDepositList = [DepositML]()
    public var currencyRate = [String: ConvertML]()

    // MARK: -

    // MARK: Private properies

    // MARK: -

    private let formatter = NumberFormatter()

    //    Isn't safety, only for example
    private var countConvertedTimes: Int {
        get { return UserDefaults().getIntNSUDByKey(key: UDKey.CountConvertedTimes) ?? 0 }
        set { UserDefaults().saveIntNSUDByKey(value: newValue, key: UDKey.CountConvertedTimes) }
    }

    // MARK: -

    // MARK: Public Methods

    // MARK: -

    func prepareData(_ completion: @escaping AnyBlock) {
        guard let deposit = userDepositList.first else { completion(true); return }

        let depoRef = ThreadSafeReference(to: deposit)

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let group = DispatchGroup()

            group.enter()

            let realm = try! Realm()
            if let deposit = realm.resolve(depoRef) {
                self?.loadCurrencyRate(sellCurrency: deposit.currency, buyCurrency: nil) { _ in group.leave() }
            } else {
                group.leave()
            }

            group.wait()

            DispatchQueue.main.async { [weak self] in
                print("✅ User data prepared!")
                completion(true)
            }
        }
    }

    func predictConvertedBalance(_ sellCurr: String?, _ buyCurr: String?, _ balance: Float) -> String {
        guard let sellCurr = sellCurr else { return "0.00" }
        guard let buyCurr = buyCurr else { return "0.00" }
        guard let currencyModel = UserAccount.sI.currencyRate[sellCurr + "-" + buyCurr] else { return "0.00" }
        guard let rate = currencyModel.amount?.floatValue else { return "0.00" }

        return getFormattedBalance(Int((balance * (rate / 100.0)) * 100))
    }

    func isConvertBalance(_ currency: String?, _ summ: String? = nil) -> UserAccountConvertStatus {
        if let summ = summ, let deposit = userDepositList.first(where: { $0.currency == currency }) {
            let takeSumm = Int(summ.floatValue * 100) + (hasCommission(summ).feeSumm)
            let availableSumm = deposit.balance ?? 0

            return takeSumm <= availableSumm ? .granded : .noBalance

        } else if userDepositList.first(where: { $0.currency == currency }) != nil {
            return .granded
        }
        return .unknown
    }

    func getFormattedBalance(_ balance: Int?) -> String {
        guard let balance = balance else { return "0.00" }
        if balance <= 0 { return "0.00" }
        return formatter.string(from: NSNumber(value: Float(balance) / 100.0)) ?? "0.00"
    }

    func addDeposide(currency curr: String, totalDepositSumm summ: Int) {
        do {
            let realm = try Realm()

            if let model = userDepositList.first(where: { $0.currency == curr }), let balance = model.balance {
                try? realm.write {
                    model.balance = balance + summ
                }
            } else {
                let deposit = DepositML(currency: curr, totalDepositSumm: summ)
                try? realm.write {
                    realm.add(deposit)
                }
                userDepositList.append(deposit)
            }

            NotificationCenter.default.post(name: .SELDidChangeDeposit, object: nil)
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
        }
    }

    func takeDeposide(currency curr: String, totalDepositSumm summ: String) {
        do {
            let realm = try Realm()

            if let model = userDepositList.first(where: { $0.currency == curr }), let balance = model.balance {
                let newBalance = balance - getSumWithFee(summ)
                try? realm.write {
                    if newBalance <= 0 {
                        realm.delete(model)
                        getDeposideList()
                    } else {
                        model.balance = newBalance
                    }
                }
            } else {
                fatalError("Error")
            }

            NotificationCenter.default.post(name: .SELDidChangeDeposit, object: nil)
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
        }
    }

    func loadCurrencyRate(sellCurrency sell: String?, buyCurrency buy: String?, _ completion: @escaping AnyBlock) {
        let sellCurrency = sell ?? "USD"
        let buyCurrency = (buy ?? currencyList.first(where: { $0 != sellCurrency })) ?? "USD"

        let params = ["balance": "100.0", "sell": sellCurrency, "buy": buyCurrency]
        convertBalance(params) { response in completion(response) }
    }

    func convert(sellCurrency sell: String, buyCurrency buy: String, depoSumm summ: String, _ completion: @escaping AnyBlock) {
        let params = ["sell": sell, "buy": buy, "balance": summ]
        APIManager.sI().getConvertBalance(params) { [weak self] response in
            switch response {
            case let .success(result):

                if
                    let balance = result.amount?.floatValue
                {
                    self?.addDeposide(currency: buy, totalDepositSumm: Int(balance * 100))
                    self?.takeDeposide(currency: sell, totalDepositSumm: summ)
                    self?.countConvertedTimes += 1
                    completion(result)
                } else {
                    completion(false)
                }

            case let .failure(error):
                print(error.localizedDescription)
                completion(false)
            }
        }
    }

    func hasCommission(_ convertSumm: String?) -> (fee: Float, feeSumm: Int) {
        let summ = convertSumm?.floatValue ?? 0.0
        let percent: Float = countConvertedTimes >= 5 ? 0.70 : 0.0
        let percentage = max((percent / 100.0) * summ, 0.01)
        if percentage.isInfinite { return (fee: percent, feeSumm: 0) }

        return (fee: percent, feeSumm: Int(percentage * 100))
    }

    func getSumWithFee(_ convertSumm: String?) -> Int {
        guard let sum = convertSumm else { return 0 }
        return Int(sum.floatValue * 100) + (hasCommission(sum).feeSumm)
    }

    // MARK: -

    // MARK: Private Methods

    // MARK: -

    private func getDeposideList() {
        do {
            let realm = try Realm()
            userDepositList = realm.objects(DepositML.self).toArray()
            NotificationCenter.default.post(name: .SELDidChangeDeposit, object: nil)

        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
        }
    }

    private func convertBalance(_ params: Parameters, _ completion: @escaping AnyBlock) {
        APIManager.sI().getConvertBalance(params) { [weak self] response in
            switch response {
            case let .success(result):

                if
                    let sellCurrency = params["sell"] as? String,
                    let buyCurrency = params["buy"] as? String
                {
                    self?.currencyRate[sellCurrency + "-" + buyCurrency] = result
                }

                completion(true)
            case let .failure(error):
                print(error.localizedDescription)
                completion(false)
            }
        }
    }
}
