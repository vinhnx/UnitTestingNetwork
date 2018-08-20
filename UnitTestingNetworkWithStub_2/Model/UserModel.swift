//
//  UserModel.swift
//  UnitTestingNetworkWithStub_2
//
//  Created by Vinh Nguyen on 20/8/18.
//  Copyright © 2018 Vinh Nguyen. All rights reserved.
//

import Foundation

struct User: Codable {
    var userName: String?
    var bio: String?

    enum CodingKeys: String, CodingKey {
        case bio
        case userName = "login"
    }
}
