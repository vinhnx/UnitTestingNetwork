//: Playground - noun: a place where people can play

import Foundation
import PlaygroundSupport
import XCTest

// Simple NSURLSession and Codable

/*
 public Github profile API "https://api.github.com/users/{user_name}"
 */

extension DateFormatter {
    static let customISO8601: DateFormatter = {
        // created_at: "2011-10-03T01:05:57Z",
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ" // iso 8601 format
        return dateFormatter
    }()
}

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
    var createdDate: Date?

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
        let dateString = try container.decode(String.self, forKey: .createdDate)
        let dateFormatter = DateFormatter.customISO8601
        if let date = dateFormatter.date(from: dateString) {
            self.createdDate = date
        } else {
            throw DecodingError.dataCorruptedError(forKey: .createdDate, in: container, debugDescription: "Date string doesn not match format expected by formatter")
        }
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

                // NOTE: actualy we should try to avoid doing this, and using `CodingKeys`
                // protocol enum overriding instead, because there is a perfomance cost, as per
                // JSONDecoder header
                // > "Note: Using a key decoding strategy has a nominal performance cost, as each string key has to be inspected for the `_` character."
                // decoder.keyDecodingStrategy = .convertFromSnakeCase

                decoder.dateDecodingStrategy = .formatted(DateFormatter.customISO8601)

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
GithubUserRequest().fetchRequest(RequestType.User.profile(username: "vinhnx")) { (result) in
    switch result {
    case .success(let user):
        user.bio
        user.userName
        user.createdDate

    case .failure(let error):
        error.message

    }
}

//GihubReposRequest().fetchRequest(RequestType.User.repos(username: "vinhnx")) { (result) in
//    switch result {
//    case .success(let repos):
//
//        repos.first.flatMap {
//            $0.fullName ?? ""
//            $0.owner?.userName ?? ""
//        }
//
//    case .failure(let error):
//        error.message
//
//    }
//}


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

// Run the test
TestUser.defaultTestSuite.run()

// Playground config
PlaygroundPage.current.needsIndefiniteExecution = true
