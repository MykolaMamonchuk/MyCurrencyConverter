//
//  APIConfiguration.swift
//  MyCurrencyConverter
//
//  Created by MMU on 14.10.2022.
//

import Alamofire
import Foundation

protocol APIConfiguration: URLRequestConvertible {
    var method: HTTPMethod { get }
    var path: String { get }
    var parameters: Parameters? { get }
    var encoding: Alamofire.ParameterEncoding? { get }
}
