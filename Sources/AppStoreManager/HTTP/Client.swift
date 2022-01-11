//
//  Client.swift
//  
//
//  Created by Mateusz Kuznik on 17/11/2019.
//

import Foundation


public struct Client {

    private let baseUrl = URL(string: "https://api.appstoreconnect.apple.com/v1/")!
    private var baseURLComponents: URLComponents {
        return URLComponents(url: baseUrl, resolvingAgainstBaseURL: false)!
    }
    private let decoder = JSONDecoder()
    public let authorizationTokenProvider: () -> String

    public init(authorizationTokenProvider: @escaping () -> String) {
        self.authorizationTokenProvider = authorizationTokenProvider
    }

    public func perform<R: Request, T>(_ request: R) async -> Result<Response<T>, Client.Error> where R.Response == T {
        let request = cocoaRequest(using: request)

        do {
            let response: Response<T> = try await URLSession.shared.response(for: request)
            return .success(response)
        } catch let error as DecodingError {
            return .failure(.couldNotDecodeObject(error))
        } catch {
            return .failure(.unknown(error))
        }
    }

    private func cocoaRequest<R: Request>(using request: R) -> URLRequest {
        var cocoaRequest = URLRequest(
            url: url(for: request),
            timeoutInterval: request.timeoutInterval)

        cocoaRequest.httpBody = request.body
        cocoaRequest.httpMethod = request.method.rawValue
        cocoaRequest.addValue("Bearer \(authorizationTokenProvider())", forHTTPHeaderField: "Authorization")
        cocoaRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")

        return cocoaRequest
    }

    private func url<R: Request>(for request: R) -> URL {
        var components = baseURLComponents
        components.queryItems = request.queryItems

        let url = components.url!.appendingPathComponent(request.path)
        return url
    }
}

extension Client {
    public enum Error: Swift.Error {
        case notHttpResponse
        case noResponseObject
        case responseError([ResponseError])
        case couldNotDecodeObject(DecodingError)
        case unknown(Swift.Error)
    }
}
