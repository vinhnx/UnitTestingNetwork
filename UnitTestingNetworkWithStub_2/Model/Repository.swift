//
//  Repository.swift
//  UnitTestingNetworkWithStub_2
//
//  Created by Vinh Nguyen on 20/8/18.
//  Copyright © 2018 Vinh Nguyen. All rights reserved.
//

import Foundation

struct Repo: Codable {
    var fullName: String?
    var owner: User?

    enum CodingKeys: String, CodingKey {
        case fullName = "full_name"
        case owner
    }
}

/// Optional snake case Codable keyDecodingStategy example
struct SnakeCaseRepo: Codable {
    var fullName: String?
}
