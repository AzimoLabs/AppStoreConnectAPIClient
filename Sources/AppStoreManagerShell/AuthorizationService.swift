//
//  AuthorizationService.swift
//  
//
//  Created by Mateusz Kuznik on 29/11/2019.
//

import Foundation
import AppStoreManagerAuthorization
import os

struct AuthorizationService {

    private struct RawData {
        let keyId: String
        let issuerId: String
        let privateKey: String
    }

    private enum InternalData {
        case commandLineService(CommandLineService)
        case rawData(RawData)
    }

    private let data: InternalData

    init(commandLineService: CommandLineService) {
        data = .commandLineService(commandLineService)
    }

    init(keyId: String,
         issuerId: String,
         privateKey: String) {

        let rawData = RawData(keyId: keyId, issuerId: issuerId, privateKey: privateKey)
        data = .rawData(rawData)
    }

    private func value(for parameter: AuthorizationParameter, using commandLineService: CommandLineService) -> Result<String, Self.Error> {
        return commandLineService
            .value(for: parameter)
            .mapError { (commandLineError) -> Error in
                return Error(message: commandLineError.message)
            }
    }

    private func rawData() -> Result<RawData, Self.Error> {
        switch data {
        case .rawData(let data):
            return .success(data)
        case .commandLineService(let service):
            let issuerIdentifier = value(for: .issuerIdentifier, using: service)

            let keyIdentifier = value(for: .keyIdentifier, using: service)
            let privateKey = value(for: .privateKey, using: service)
            return issuerIdentifier
                .concatenate(keyIdentifier, mapError: mapError)
                .concatenate(privateKey, mapError: mapError)
                .map { (values) -> RawData in
                    return RawData(keyId: values.success.other, issuerId: values.success.success, privateKey: values.other)
                }
        }
    }

    func authorizationToken() -> Result<String, Self.Error> {

        let token = rawData()
                .flatMap({ (data) -> Result<(AppStoreConnectSigner, privateKey: Data), Self.Error> in
                    guard let privateKey = data.privateKey.data(using: .utf8) else {
                        return .failure(.init(message: "Provided private key is invalid"))
                    }
                    let payload = AppStoreConnectPayload(issuerIdentifier: data.issuerId)
                    return .success((AppStoreConnectSigner(keyIdentifier: data.keyId, payload: payload), privateKey))
                })
                .flatMap { (signerAndPrivateKey) -> Result<String, Self.Error> in
                    let (signer, privateKey)  = signerAndPrivateKey
                    do {
                        let token = try signer.generateJWTToken(usingPrivateKey: privateKey)
                        return .success(token)
                    } catch {
                        return .failure(.init(message: "Could not generate JWT token"))
                    }
            }
        return token
    }

    private func mapError<Enything>(error: Result<Enything, Self.Error>.ConcatenatedError<Self.Error>) -> Self.Error {

        switch error {
        case let .both(payloadError, keyIdentifierError):
            return .init(message: "\(payloadError.message)\n\(keyIdentifierError.message)")
        case let .failure(error),
             let .other(error):
            return error
        }
    }
}

extension AuthorizationService {

    struct Error: Swift.Error {
        /// The message do not have any private data
        let message: String
    }
}
