//
//  NVError.swift
//  UnitTestingNetworkWithStub_2
//
//  Created by Vinh Nguyen on 20/8/18.
//  Copyright © 2018 Vinh Nguyen. All rights reserved.
//

import Foundation

enum NVError: Error {
    case invalidURL(username: String)
    case sessionDataTask(error: Error)
    case decoder(error: Error)

    case custom(message: String, code: Int)

    var message: String {
        switch self {
        case .invalidURL(let username):
            return "unable to make GitHub URL request with username: \(username)"

        case .sessionDataTask(let error):
            return "session data task error \(error)"

        case .decoder(let error):
            return "request decoder error \(error)"

        case .custom(let message, let code):
            return "custom error. Message: \(message), code: \(code)"
        }
    }
}
