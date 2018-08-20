//: Playground - noun: a place where people can play

import Foundation
import PlaygroundSupport
import XCTest

// Simple NSURLSession and Codable

/*
 public Github profile API "https://api.github.com/users/{user_name}"
 */

struct Repo: Codable {
    var fullName: String?
    var owner: User?

    enum CodingKeys: String, CodingKey {
        case fullName = "full_name"
        case owner
    }
}

struct SnakeCaseRepo: Codable {
    var fullName: String?
}

struct User: Codable {
    var userName: String?
    var bio: String?

    enum CodingKeys: String, CodingKey {
        case bio
        case userName = "login"
    }
}

enum NVError: Error {
    case invalidURL(username: String)
    case sessionDataTask(error: Error)
    case decoder(error: Error)

    var message: String {
        switch self {
        case .invalidURL(let username):
            return "unable to make GitHub URL request with username: \(username)"

        case .sessionDataTask(let error):
            return "session data task error \(error)"

        case .decoder(let error):
            return "request decoder error \(error)"
        }
    }
}

enum Result<T> {
    case success(T)
    case failure(NVError)
}

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

/// Base network request. Conformers just need to provide `Model` associated type
protocol NetworkRequest {
    typealias ModelCompletion = (Result<Model>) -> Void

    associatedtype Model: Codable
}

extension NetworkRequest {
    /// Default GET request
    ///
    /// - Parameters:
    ///   - requestType: request type
    ///   - completion: result completion
    func fetchRequest(_ requestType: RequestType.User, completion: @escaping ModelCompletion) {
        guard let url = requestType.url else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        URLSession(configuration: URLSessionConfiguration.default)
            .dataTask(with: request) { (data, response, error) in
            guard let data = data else {

                error.flatMap {
                    completion(.failure(NVError.sessionDataTask(error: $0)))
                }

                return
            }

            do {
                let decoder = JSONDecoder()

                // check
                 decoder.keyDecodingStrategy = .convertFromSnakeCase

                let model = try decoder.decode(Model.self, from: data)
                completion(.success(model))

            } catch (let decoderError) {
                // error handling
                completion(.failure(NVError.decoder(error: decoderError)))
            }

            }.resume()
    }
}

final class GithubUserRequest: NetworkRequest {
    typealias Model = User
}

final class GihubReposRequest: NetworkRequest {
    typealias Model = [Repo]
}

final class GithubSnakecaseReposRequest: NetworkRequest {
    typealias Model = [SnakeCaseRepo]
}

// Test
//GithubUserRequest().fetchRequest(RequestType.User.profile(username: "vinhnx")) { (result) in
//    switch result {
//    case .success(let user):
//        user.bio
//        user.userName
//
//    case .failure(let error):
//        error.message
//
//    }
//}

GihubReposRequest().fetchRequest(RequestType.User.repos(username: "vinhnx")) { (result) in
    switch result {
    case .success(let repos):

        repos.first.flatMap {
            $0.fullName ?? ""
            $0.owner?.userName ?? ""
        }

    case .failure(let error):
        error.message

    }
}


//GithubSnakecaseReposRequest().fetchRequest(RequestType.User.repos(username: "vinhnx")) { (result) in
//    switch result {
//    case .success(let repos):
//
//        repos.first.flatMap {
//            $0.fullName ?? ""
////            $0.owner?.userName ?? ""
////            $0.repoDescription ?? ""
////            $0.url ?? ""
//        }
//
//    case .failure(let error):
//        error.message
//
//    }
//}

// XCTest
class TestUser: XCTestCase {
    var testUser: User!

    // MARK: - Setup

    override func setUp() {
        testUser = User(userName: "vinhnx", bio: "hello")
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
        testUser = nil
    }

    // MARK: - Test cases

    func testCustomUserName() {
        XCTAssertTrue(testUser.userName == "vinhnx")
    }

    func testEncodeUserToData() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(testUser)
            XCTAssertNotNil(data)

        } catch (let encodingError) {
            print(encodingError)
        }
    }

    func testEncodeUserToJSON() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(testUser)

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
            let data = try encoder.encode(testUser)

            let jsonString = String(data: data, encoding: .utf8)
            XCTAssertNotNil(jsonString)

        } catch (let encodingError) {
            print(encodingError)
        }
    }

    func testDecodeToUserFromJSONString() {
        let data = "{\"bio\":\"hello\",\"login\":\"vinhnx\"}".data(using: .utf8)

        do {
            let decoder = JSONDecoder()
            let user = try decoder.decode(User.self, from: data!)
            XCTAssertTrue(user.userName == "vinhnx")
        } catch (let decodingError) {
            print(decodingError)
        }
    }

    func testNetworkRequest() {
        let expect = XCTestExpectation(description: "expect from network request")
        GithubUserRequest().fetchRequest(RequestType.User.profile(username: "vinhnx")) { (result) in
            switch result {
            case .success(let user):
                XCTAssertTrue(user.userName == "vinhnx")

            default:
                break
            }

            expect.fulfill()
        }

        wait(for: [expect], timeout: 5.0)
    }
}

// Run the test
TestUser.defaultTestSuite.run()

// Playground config
PlaygroundPage.current.needsIndefiniteExecution = true
