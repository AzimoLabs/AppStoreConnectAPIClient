//
//  Client.swift
//  
//
//  Created by Mateusz Kuznik on 17/11/2019.
//

import Foundation
import Combine

struct BodyParameters<T: Encodable>: Encodable {
    let data: T
}

public struct DecodableDataObject<T: Decodable>: Decodable {
    public let data: T
}

extension AnyPublisher {

    static func just<Output, Failure: Error>(_ item: Output) -> AnyPublisher<Output, Failure> {
        return Just(item).mapError { (never) -> Failure in }.eraseToAnyPublisher()
    }

    static func fail<Output, Failure: Error>(_ error: Failure) -> AnyPublisher<Output, Failure> {
        return Fail(error: error).eraseToAnyPublisher()
    }
}

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

    public func perform<R: Request, T>(_ request: R) -> AnyPublisher<Response<T>, Client.Error> where R.Response == T {

        let request = cocoaRequest(using: request)
        let publisher: URLSession.DataTaskPublisher = URLSession.shared
            .dataTaskPublisher(for: request)
        return publisher
            .mapError { Client.Error.unknown($0) }
            .flatMap { (dataWithResponse) -> AnyPublisher<Response<T>, Client.Error> in
                let (data, response) = dataWithResponse
                guard let httpResponse = response as? HTTPURLResponse else {
                    return .fail(Error.notHttpResponse)
                }

                if httpResponse.statusCode < 300 {
                    return SuccessPublisher(data: data).eraseToAnyPublisher()
                } else {
                    return FailPublisher(data: data)
                        .map { (never) -> Response<T> in }
                        .eraseToAnyPublisher()
                }

            }
            .eraseToAnyPublisher()
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

        //TODO - error handling
        let url = components.url!.appendingPathComponent(request.path)
        return url
    }
}

extension Client {
    public enum Error: Swift.Error {
        case notHttpResponse
        case responseError([ResponseError])
        case couldNotDecodeErrorObject(DecodingError)
        case unknown(Swift.Error)
    }
}

extension Client {
    private struct SuccessPublisher<Output: Decodable>: Publisher {

        typealias Failure = Client.Error
        private let item: Result<Output, Failure>

        init(data: Data) {
            let decoder = JSONDecoder()
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_GB_POSIX")
            dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSZ"
            decoder.dateDecodingStrategy = .formatted(dateFormatter)
            do {
                let object = try decoder.decode(Output.self, from: data)
                item = .success(object)
            } catch let error as DecodingError {
                item = .failure(.couldNotDecodeErrorObject(error))
            } catch {
                item = .failure(.unknown(error))
            }
        }

        func receive<S>(subscriber: S) where S : Subscriber, SuccessPublisher.Failure == S.Failure, SuccessPublisher.Output == S.Input {

            switch item {
            case let .success(output):
                _ = subscriber.receive(output)
                subscriber.receive(completion: .finished)
            case let .failure(error):
                subscriber.receive(completion: .failure(error))
            }
        }

    }

    private struct FailPublisher: Publisher  {

        private struct ErrorContainer: Decodable {
            let errors: [ResponseError]
        }

        typealias Failure = Client.Error
        typealias Output = Never

        private let item: Failure

        init(data: Data) {
            let decoder = JSONDecoder()

            do {
                let responseError = try decoder.decode(ErrorContainer.self, from: data)
                item = .responseError(responseError.errors)
            } catch let error as DecodingError {
                item = .couldNotDecodeErrorObject(error)
            } catch {
                item = .unknown(error)
            }
        }

        func receive<S>(subscriber: S) where S : Subscriber, FailPublisher.Failure == S.Failure, FailPublisher.Output == S.Input {

            subscriber.receive(completion: .failure(item))
        }
    }
}

/// https://developer.apple.com/documentation/appstoreconnectapi/errorresponse/errors
public struct ResponseError: Decodable, Error {

    /// The HTTP status code of the error. This status code usually matches the response's status code; however, if the request produces multiple errors, these two codes may differ.
    public let status: String
    /// A machine-readable code indicating the type of error. The code is a hierarchical value with levels of specificity separated by the '.' character. This value is parseable for programmatic error handling in code.
    public let code: String
    /// The unique ID of a specific instance of an error, request, and response. Use this ID when providing feedback to or debugging issues with Apple.
    public let identifier: String?
    /// A summary of the error. Do not use this field for programmatic error handling.
    public let title: String
    /// A detailed explanation of the error. Do not use this field for programmatic error handling.
    public let detail: String
    /// One of two possible types of values: source.parameter, provided when a query parameter produced the error, or source.JsonPointer, provided when a problem with the entity produced the error.
    ///
    /// Possible types:
    /// 1. (ErrorResponse.Errors.JsonPointer)[https://developer.apple.com/documentation/appstoreconnectapi/errorresponse/errors/jsonpointer],
    /// 1. (ErrorResponse.Errors.Parameter)[https://developer.apple.com/documentation/appstoreconnectapi/errorresponse/errors/parameter]
    public let source: [String: String]?

    internal init(
        status: String,
        code: String,
        identifier: String?,
        title: String,
        detail: String,
        source: [String: String]?) {
        
        self.status = status
        self.code = code
        self.identifier = identifier
        self.title = title
        self.detail = detail
        self.source = source
    }
}
