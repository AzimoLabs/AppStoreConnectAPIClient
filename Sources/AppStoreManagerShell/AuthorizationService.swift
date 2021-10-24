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

    private let data: RawData

    init(keyId: String,
         issuerId: String,
         privateKey: String) {

        let rawData = RawData(keyId: keyId, issuerId: issuerId, privateKey: privateKey)
        data = rawData
    }

    func authorizationToken() -> Result<String, Self.Error> {
        return createPrivateKey(for: data.privateKey)
                .map { (privateKey) -> (AppStoreConnectSigner, privateKey: Data) in
                    let payload = AppStoreConnectPayload(issuerIdentifier: self.data.issuerId)
                    return (AppStoreConnectSigner(keyIdentifier: self.data.keyId, payload: payload), privateKey)
                }
                .flatMap { (signerAndPrivateKey) -> Result<String, Self.Error> in
                    let (signer, privateKey)  = signerAndPrivateKey
                    do {
                        let token = try signer.generateJWTToken(usingPrivateKey: privateKey)
                        return .success(token)
                    } catch {
                        return .failure(.init(message: "Could not generate JWT token"))
                    }
            }
    }

    private func createPrivateKey(for privateToken: String) -> Result<Data, Self.Error> {
        guard let privateKey = data.privateKey.data(using: .utf8) else {
            return .failure(.init(message: "Provided private key is invalid"))
        }
        return .success(privateKey)
    }

    private func mapError<Anything>(error: Result<Anything, Self.Error>.ConcatenatedError<Self.Error>) -> Self.Error {

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
