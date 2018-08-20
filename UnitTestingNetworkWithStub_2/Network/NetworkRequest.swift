//
//  NetworkRequest.swift
//  UnitTestingNetworkWithStub_2
//
//  Created by Vinh Nguyen on 20/8/18.
//  Copyright © 2018 Vinh Nguyen. All rights reserved.
//

import Foundation

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

                    // date formatter, if the formmater is in ISO 8601 format, we could use
                    // `dateDecodingStrategy`'s `.iso8601`
                    // but it is less customizable and iOS 10+ only
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
