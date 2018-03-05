//
//  EasyNetworkManager.swift
//  Easy Network Requester
//
//  Created by Dean Qiu on 3/5/18.
//  Copyright © 2018 casenderqiu. All rights reserved.
//

import Foundation

protocol ApiRequest {
    var urlRequest: URLRequest { get }
}

struct ApiParseError: Error {
    static let code = 999
    
    let error: Error
    let httpUrlResponse: HTTPURLResponse
    let data: Data?
    
    var localizedDescription: String {
        return error.localizedDescription
    }
}

struct EasyNetworkApiResponse<T: Codable> {
    let entity: T
    let httpUrlResponse: HTTPURLResponse
    
    init(data: Data, httpUrlResponse: HTTPURLResponse) throws {
        do {
            let decoder = JSONDecoder()
            self.entity = try decoder.decode(T.self, from: data)
            self.httpUrlResponse = httpUrlResponse
        } catch {
            throw ApiParseError(error: error, httpUrlResponse: httpUrlResponse, data: data)
        }
    }
}

class EasyNetworkApiManager {
    var request: ApiRequest
    
    init(request: ApiRequest) {
        self.request = request
    }
    
    func execute<T>(completionHandler: @escaping (Result<EasyNetworkApiResponse<T>>) -> Void) {
        let task = URLSession.shared.dataTask(with: request.urlRequest) { (data, response, error) in
            guard let httpUrlResponse = response as? HTTPURLResponse else {
                completionHandler(.failure(CoreError(message: "The Internet connection appears to be offline.")))
                return
            }
            let successRange = 200...299
            if successRange.contains(httpUrlResponse.statusCode) {
                do {
                    if let data = data {
                        let response = try EasyNetworkApiResponse<T>(data: data, httpUrlResponse: httpUrlResponse)
                        completionHandler(.success(response))
                    } else {
                        completionHandler(.failure(CoreError(message: "The server appears to be offline at the moment.")))
                    }
                } catch {
                    completionHandler(.failure(error))
                }
            } else {
                completionHandler(.failure(CoreError(message: "The server appears to be offline at the moment.")))
            }
        }
        task.resume()
    }
}






