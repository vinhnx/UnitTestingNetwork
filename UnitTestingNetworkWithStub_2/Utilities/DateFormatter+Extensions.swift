//
//  DateFormatter+Extensions.swift
//  UnitTestingNetworkWithStub_2
//
//  Created by Vinh Nguyen on 20/8/18.
//  Copyright © 2018 Vinh Nguyen. All rights reserved.
//

import Foundation

extension DateFormatter {
    static let customISO8601: DateFormatter = {
        // created_at: "2011-10-03T01:05:57Z",
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ" // iso 8601 format
        return dateFormatter
    }()
}
