//
//  URLBUilder.swift
//  UnitTestingNetworkWithStub_2
//
//  Created by Vinh Nguyen on 20/8/18.
//  Copyright © 2018 Vinh Nguyen. All rights reserved.
//

import Foundation

struct URLBuilder {
    static var baseURL: URL? {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "api.github.com"
        urlComponents.path = "/users"
        return urlComponents.url
    }

    static func makeGitHubURLFromUsername(_ username: String) -> URL? {
        return self.baseURL?.appendingPathComponent("/\(username)", isDirectory: false)
    }

    static func makeGitHubReposURLFromUsername(_ username: String) -> URL? {
        return self.baseURL?.appendingPathComponent("/\(username)/repos", isDirectory: false)
    }
}
