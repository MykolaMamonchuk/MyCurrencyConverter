//
//  APIManager.swift
//  MyCurrencyConverter
//
//  Created by MMU on 14.10.2022.
//

import Alamofire
import CodableAlamofire

typealias Response<T> = (Result<T, APIError>) -> Void
typealias EmptyResponse = (Result<Void, APIError>) -> Void

final class APIManager {
    // MARK: - Const

    enum Result<T> {
        case success(T)
        case failure((String, String))
    }

    // MARK: - Shared Instance

    class func sI() -> APIManager {
        return APIManager()
    }

    // MARK: - Initialization

    private init() {}

    // MARK: - PERFORM METHODS

    private func performRequest<T: Codable>(router: BaseRouter, decoder: JSONDecoder = JSONDecoder(), completion: @escaping Response<T>) {
        AF.request(router).validate(statusCode: 200 ..< 300).responseDecodable(decoder: decoder) { (response: AFDataResponse<T>) in

            let statusCode = response.response?.statusCode ?? -1

            if statusCode == 401 {
                DispatchQueue.main.async {
                    AF.session.getAllTasks { tasks in
                        tasks.forEach { $0.cancel() }
                    }

                    if let error = self.parseAmazonApiError(data: response.data, statusCode) {
                        completion(.failure(error))
                    } else {
                        completion(.failure(self.parseApiError(data: response.data, statusCode)))
                    }
                }
                return
            }

            switch response.result {
            case let .success(object):
                completion(.success(object))
            case let .failure(err):
                if response.data == nil {
                    completion(.failure(.failedAPICall(err.localizedDescription, code: err.responseCode ?? -1)))
                } else if let error = self.parseAmazonApiError(data: response.data, statusCode) {
                    completion(.failure(error))
                } else {
                    completion(.failure(self.parseApiError(data: response.data, statusCode)))
                }
            }
        }
    }

    private func performRequest(router: BaseRouter, completion: @escaping EmptyResponse) {
        AF.request(router).validate().response { response in

            let statusCode = response.response?.statusCode ?? -1
            if statusCode == 401 {
                DispatchQueue.main.async {
                    AF.session.getAllTasks { tasks in
                        tasks.forEach { $0.cancel() }
                    }
                    if let error = self.parseAmazonApiError(data: response.data, statusCode) {
                        completion(.failure(error))
                    } else {
                        completion(.failure(self.parseApiError(data: response.data, statusCode)))
                    }
                }
                return
            }

            switch response.result {
            case .success:
                completion(.success(()))
            case let .failure(err):
                if response.data == nil {
                    completion(.failure(.failedAPICall(err.localizedDescription, code: statusCode)))
                } else if let error = self.parseAmazonApiError(data: response.data, statusCode) {
                    completion(.failure(error))
                } else {
                    completion(.failure(self.parseApiError(data: response.data, statusCode)))
                }
            }
        }
    }

    fileprivate func performUpload<T: Codable>(router: BaseRouter, completion: @escaping Response<T>) {
        let formData = MultipartFormData(fileManager: .default, boundary: "custom-test-boundary")
        if let params = router.parameters {
            for (key, value) in params {
                if value is UIImage {
                    if let imageData = (value as! UIImage).jpegData(compressionQuality: 0.5) {
                        formData.append(imageData, withName: key, fileName: UUID().uuidString + ".jpg", mimeType: "image/jpeg")
                    } else if let imageData = (value as! UIImage).pngData() {
                        formData.append(imageData, withName: key, fileName: UUID().uuidString + ".png", mimeType: "image/png")
                    }
                }
                if value is Data {
                    if let data = value as? Data {
                        formData.append(data, withName: key)
                    }
                }
            }
        }

        AF.upload(multipartFormData: formData, with: router)
            .uploadProgress(queue: .main, closure: { progress in
                // Current upload progress of file
                print("Upload Progress: \(progress.fractionCompleted)")
            })
            .validate(statusCode: 200 ..< 300)
            .responseDecodable(completionHandler: { (response: AFDataResponse<T>) in
                switch response.result {
                case let .success(object):
                    completion(.success(object))
                case let .failure(err):
                    if response.data == nil {
                        completion(.failure(.failedAPICall(err.localizedDescription, code: err.responseCode ?? -1)))
                    } else {
                        completion(.failure(self.parseApiError(data: response.data, err.responseCode ?? -1)))
                    }
                }
            })
    }

    fileprivate func performUpload(router: BaseRouter, onProgress: @escaping (Float?) -> Void, completion: @escaping EmptyResponse) {
        let formData = MultipartFormData(fileManager: .default, boundary: "custom-test-boundary")

        if let params = router.parameters {
            for (key, value) in params {
                if value is UIImage {
                    if let imageData = (value as! UIImage).jpegData(compressionQuality: 0.5), !imageData.isEmpty {
                        formData.append(imageData, withName: key, fileName: UUID().uuidString + ".jpg", mimeType: "image/jpeg")
                    } else if let imageData = (value as! UIImage).pngData() {
                        formData.append(imageData, withName: key, fileName: UUID().uuidString + ".png", mimeType: "image/png")
                    }
                }
                if value is Data {
                    if let videoData = value as? Data {
                        formData.append(videoData, withName: key, fileName: UUID().uuidString + ".mp4", mimeType: "video/mp4")
                    }
                }
            }
        }

        AF.upload(multipartFormData: formData, with: router)
            .uploadProgress(queue: .main, closure: { progress in
                // Current upload progress of file
                print("Upload Progress: \(progress.fractionCompleted)")
                onProgress(Float(progress.fractionCompleted))
            })
            .validate(statusCode: 200 ..< 300)
            .response(completionHandler: { response in
                switch response.result {
                case .success:
                    completion(.success(()))
                case let .failure(err):
                    if response.data == nil {
                        completion(.failure(.failedAPICall(err.localizedDescription, code: err.responseCode ?? -1)))
                    } else {
                        completion(.failure(self.parseApiError(data: response.data, err.responseCode ?? -1)))
                    }
                }
            })
    }

    // -------------------------------------------------------------------------------------------

    // MARK: - HANDLE ERRORS

    // -------------------------------------------------------------------------------------------

    fileprivate func parseAmazonApiError(data: Data?, _ status: Int) -> APIError? {
        guard
            let errorResponseData = data,
            let errorData = try? JSONSerialization.jsonObject(with: errorResponseData) as? [String: Any]
        else {
            return .failedAPICall(requestError, code: status)
        }

        if
            let errorList = (errorData["message"] as? String)?.data(using: .utf8),
            let errorMessage = (try? JSONSerialization.jsonObject(with: errorList) as? [String: Any])?["message"] as? String
        {
            return .failedAPICall(errorMessage, code: status)
        } else if let message = errorData["message"] as? String {
            return .failedAPICall(message, code: status)
        } else if let error = errorData["error"] as? String {
            return .failedAPICall(error, code: status)
        } else {
            return .failedAPICall(requestError, code: status)
        }
    }

    fileprivate func parseApiError(data: Data?, _ status: Int) -> APIError {
        guard let data = data, let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return .failedAPICall(requestError, code: status)
        }

        guard let messageBlock = json["error"] as? [String: Any] else {
            return .failedAPICall(requestError, code: status)
        }

        let mesages = messageBlock["message"] as? String

        return .failedAPICall(mesages ?? requestError, code: status)
    }

    // -------------------------------------------------------------------------------------------

    // MARK: - CONVERTER METHODS

    // -------------------------------------------------------------------------------------------

    func getConvertBalance(_ params: Parameters, completion: @escaping Response<ConvertML>) {
        let router = ConvertRouter(anEndpoint: .getConvert(params))
        performRequest(router: router, completion: completion)
    }
}
