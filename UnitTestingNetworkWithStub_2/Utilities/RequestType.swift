//
//  RequestType.swift
//  UnitTestingNetworkWithStub_2
//
//  Created by Vinh Nguyen on 20/8/18.
//  Copyright © 2018 Vinh Nguyen. All rights reserved.
//

import Foundation

enum RequestType {
    enum User {
        case profile(username: String)
        case repos(username: String)

        var url: URL? {
            switch self {
            case .profile(let username):
                return URLBuilder.makeGitHubURLFromUsername(username)

            case .repos(let username):
                return URLBuilder.makeGitHubReposURLFromUsername(username)

            }
        }
    }
}
