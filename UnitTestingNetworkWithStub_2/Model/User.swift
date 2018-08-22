//
//  UserModel.swift
//  UnitTestingNetworkWithStub_2
//
//  Created by Vinh Nguyen on 20/8/18.
//  Copyright © 2018 Vinh Nguyen. All rights reserved.
//

import Foundation

struct User: Codable {
    let userName: String?
    let bio: String?
    let createdDate: Date?

    enum CodingKeys: String, CodingKey {
        case bio
        case userName = "login"
        case createdDate = "created_at"
    }
}

extension User {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userName = try container.decode(String.self, forKey: .userName)
        self.bio = try container.decode(String.self, forKey: .bio)

        // custom date formatter
        // reference: https://useyourloaf.com/blog/swift-codable-with-custom-dates/
        let dateString = try container.decode(String.self, forKey: .createdDate)
        let dateFormatter = DateFormatter.customISO8601
        if let date = dateFormatter.date(from: dateString) {
            self.createdDate = date
        } else {
            throw DecodingError.dataCorruptedError(forKey: .createdDate, in: container, debugDescription: "Date string doesn not match format expected by formatter")
        }
    }
}
