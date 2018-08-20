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
