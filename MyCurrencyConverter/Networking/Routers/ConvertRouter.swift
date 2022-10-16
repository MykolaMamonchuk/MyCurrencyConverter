//
//  ConvertRouter.swift
//  MyCurrencyConverter
//
//  Created by MMU on 14.10.2022.
//

import Alamofire
import Foundation

enum ConvertEndpoint {
    case getConvert(Parameters)
}

class ConvertRouter: BaseRouter {
    fileprivate var endPoint: ConvertEndpoint

    init(anEndpoint: ConvertEndpoint) {
        endPoint = anEndpoint
    }

    override var method: HTTPMethod {
        switch endPoint {
        case .getConvert: return .get
        }
    }

    override var path: String {
        switch endPoint {
        case let .getConvert(params):
            let balance = (params["balance"] as? String) ?? "0.0"
            let sell = (params["sell"] as? String) ?? "USD"
            let buy = (params["buy"] as? String) ?? "EUR"

            return "currency/commercial/exchange/\(balance)-\(sell)/\(buy)/latest"
        }
    }

    override var parameters: Parameters? {
        switch endPoint {
        default: return nil
        }
    }

    override var keyPath: String? {
        return nil
    }

    override var encoding: ParameterEncoding? {
        switch method {
        case .get:
            return URLEncoding.default
        default:
            return JSONEncoding.default
        }
    }
}
