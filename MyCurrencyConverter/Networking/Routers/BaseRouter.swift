//
//  BaseRouter.swift
//  MyCurrencyConverter
//
//  Created by MMU on 14.10.2022.
//

import Alamofire
import Foundation

let kServerBaseURL = APIConstants.baseURL

class BaseRouter: APIConfiguration {
    init() {}

    var encoding: ParameterEncoding? {
        fatalError("[\(self) - \(#function))] Must be overridden in subclass")
    }

    var method: HTTPMethod {
        fatalError("[\(self) - \(#function))] Must be overridden in subclass")
    }

    var path: String {
        fatalError("[\(self) - \(#function))] Must be overridden in subclass")
    }

    var parameters: Parameters? {
        fatalError("[\(self) - \(#function))] Must be overridden in subclass")
    }

    var keyPath: String? {
        fatalError("[\(self) - \(#function))] Must be overridden in subclass")
    }

    func asURLRequest() throws -> URLRequest {
        let url = try APIConstants.baseURL.asURL()

        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue
        urlRequest.timeoutInterval = 25

        urlRequest.setValue(APIConstants.contentType, forHTTPHeaderField: "content-type")

        if let encoding = encoding {
            return try encoding.encode(urlRequest, with: parameters)
        }

        return urlRequest
    }
}
