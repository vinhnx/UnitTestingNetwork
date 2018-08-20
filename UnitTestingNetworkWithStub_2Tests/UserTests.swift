//
//  UserTests.swift
//  UnitTestingNetworkWithStub_2
//
//  Created by Vinh Nguyen on 20/8/18.
//  Copyright © 2018 Vinh Nguyen. All rights reserved.
//

import XCTest
@testable import UnitTestingNetworkWithStub_2

class UserTests: XCTestCase {

    var testUser: User?
    var testUserData: Data!

    // MARK: - Setup

    override func setUp() {
        super.setUp()
        setupValues()
    }

    override func tearDown() {
        super.tearDown()
        self.testUser = nil
    }

    // MARK: - Test cases

    func testEncodeUserToData() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(self.testUser)
            XCTAssertNotNil(data)

        } catch (let encodingError) {
            print(encodingError)
        }
    }

    func testEncodeUserToJSON() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(self.testUser)

            do {
                let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: Any]
                XCTAssertNotNil(json)

            } catch (let jsonSerializationError) {
                print(jsonSerializationError)
            }

        } catch (let encodingError) {
            print(encodingError)
        }
    }

    func testEncodeUserToJSONString() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(self.testUser)

            let jsonString = String(data: data, encoding: .utf8)
            XCTAssertNotNil(jsonString)

        } catch (let encodingError) {
            print(encodingError)
        }
    }

    func testDecodeToUserFromJSONString() {
        do {
            let decoder = JSONDecoder()
            let user = try decoder.decode(User.self, from: self.testUserData)
            XCTAssertTrue(user.createdDate == DateFormatter.customISO8601.date(from: "2011-10-03T01:05:57Z"))
        } catch (let decodingError) {
            print(decodingError)
        }
    }
}

extension UserTests {
    func setupValues() {
        // IMPORTANT: order matters
        self.testUserData = "{\"bio\": \"hello\",\"login\":\"vinhnx\",\"created_at\": \"2011-10-03T01:05:57Z\"}".data(using: .utf8)!
        self.testUser = makeTestUser()
    }

    func makeTestUser() -> User? {
        let decoder = JSONDecoder()
        return try? decoder.decode(User.self, from: self.testUserData)
    }
}
