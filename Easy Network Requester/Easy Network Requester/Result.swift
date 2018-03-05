//
//  Result.swift
//  Easy Network Requester
//
//  Created by Dean Qiu on 3/5/18.
//  Copyright © 2018 casenderqiu. All rights reserved.
//

import Foundation

struct CoreError: Error {
    var localizedDescription: String {
        return message
    }
    var message = ""
}

enum Result<T> {
    case success(T)
    case failure(Error)
    
    public func dematerialize() throws -> T {
        switch self {
        case let .success(value):
            return value
        case let .failure(error):
            throw error
        }
    }
}
