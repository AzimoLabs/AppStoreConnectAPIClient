//
//  AsyncURLSession.swift
//  
//
//  Created by Mateusz Kuznik on 30/12/2021.
//

import Foundation

extension URLSession {

    internal func response<Response: Decodable>(for request: URLRequest) async throws -> Response {
        return try await withCheckedThrowingContinuation { continuation in
            let dataTask = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let response = response as? HTTPURLResponse else {
                    continuation.resume(throwing: Client.Error.notHttpResponse)
                    return
                }
                guard let data = data else {
                    continuation.resume(throwing: Client.Error.noResponseObject)
                    return
                }
                guard (200 ..< 300).contains(response.statusCode) else {
                    do {
                        let errorObject = try ResponseDataParser.decodeErrorObject(data)
                        continuation.resume(throwing: Client.Error.responseError(errorObject))
                    } catch {
                        continuation.resume(throwing: error)
                    }
                    return
                }
                do {
                    let responseObject: Response = try ResponseDataParser.decodeResponseObject(data)
                    continuation.resume(returning: responseObject)
                } catch {
                    continuation.resume(throwing: error)
                    return
                }
            }
            dataTask.resume()
        }
    }
}

fileprivate struct ResponseDataParser {

    private init() {}

    static func decodeResponseObject<Output: Decodable>(_ object: Data) throws -> Output {
        let decoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_GB_POSIX")
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSZ"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)

        return try decoder.decode(Output.self, from: object)
    }

    private struct ErrorContainer: Decodable {
        let errors: [ResponseError]
    }

    static func decodeErrorObject(_ object: Data) throws -> [ResponseError] {
        let decoder = JSONDecoder()
        return try decoder.decode(ErrorContainer.self, from: object).errors
    }

}
