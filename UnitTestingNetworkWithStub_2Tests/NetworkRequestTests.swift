//
//  UnitTestingNetworkWithStub_2Tests.swift
//  UnitTestingNetworkWithStub_2Tests
//
//  Created by Vinh Nguyen on 19/8/18.
//  Copyright © 2018 Vinh Nguyen. All rights reserved.
//

import XCTest
import Mockingjay
@testable import UnitTestingNetworkWithStub_2

/*
 NOTE:
 by using Mockingjay's `stub(matcher, builder)` pattern
 any request to matcher(uri()) will be swizzling to
 our .json file instead, so no real network request
 is called, keeping our real server intact

 in this example, we choose to stub any request to
 https://api.github.com/users/vinhnx
 as it is our endpoint of the
 RequestType.User.profile(username: "vinhnx")
 */

class NetworkRequestTests: XCTestCase {
    var dataPath: URL?

    override func setUp() {
        super.setUp()

        let path = Bundle(for: type(of: self)).path(forResource: "vinhnx", ofType: "json")!
        self.dataPath = URL.init(fileURLWithPath: path, isDirectory: false)
    }
    
    override func tearDown() {
        self.dataPath = nil
        super.tearDown()
    }

    func testReturnUserInfo() {
        do {
            var user: User?

            let data = try Data.init(contentsOf: self.dataPath!, options: Data.ReadingOptions.alwaysMapped)
            let stubbingURL = uri("https://api.github.com/users/vinhnx")
            let builder = jsonData(data)

            // start faking/stub
            self.stub(stubbingURL, builder)

            let expect = XCTestExpectation(description: "expecting username matches")
            GithubUserRequest().fetchRequest(RequestType.User.profile(username: "vinhnx")) { (result) in
                switch result {
                case .success(let userResponse):
                    user = userResponse
                    XCTAssertTrue(user?.userName == "vinhnx")

                case .failure(let error):
                    fatalError(error.localizedDescription)
                }

                expect.fulfill()
            }


            wait(for: [expect], timeout: 10.0)

        } catch {
            fatalError(error.localizedDescription)
        }
    }

    func testUserCreatedDateFormatter() {
        do {
            var user: User?

            let data = try Data.init(contentsOf: self.dataPath!, options: Data.ReadingOptions.alwaysMapped)
            let stubbingURL = uri("https://api.github.com/users/vinhnx")
            let builder = jsonData(data)
            stub(stubbingURL, builder)

            let expect = XCTestExpectation(description: "expecting user created date formatter")
            GithubUserRequest().fetchRequest(RequestType.User.profile(username: "vinhnx")) { (result) in
                switch result {
                case .success(let userResponse):
                    user = userResponse
                    XCTAssertTrue(user?.createdDate == DateFormatter.customISO8601.date(from: "2011-10-03T01:05:57Z"))

                case .failure(let error):
                    fatalError(error.localizedDescription)
                }

                expect.fulfill()
            }


            wait(for: [expect], timeout: 10.0)

        } catch {
            fatalError(error.localizedDescription)
        }
    }

    func testCustomError() {
        var testingError: NSError?

        let stubbingURL = uri("https://api.github.com/users/vinhnx")
        let customError = NSError(domain: "com.vinhnx.error.domain", code: 404, userInfo: nil)
        let builder = failure(customError)
        stub(stubbingURL, builder)

        let expect = XCTestExpectation(description: "expect to return custom error")
        GithubUserRequest().fetchRequest(RequestType.User.profile(username: "vinhnx")) { (result) in
            switch result {
            case .success(let userResponse):
                print(userResponse)

            case .failure(let error):
                testingError = error as NSError
                XCTAssertNotNil(testingError)
            }

            expect.fulfill()
        }


        wait(for: [expect], timeout: 10.0)
    }
}
