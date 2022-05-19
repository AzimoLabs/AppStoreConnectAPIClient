//
//  AuthorizationService.swift
//  
//
//  Created by Mateusz Kuznik on 29/11/2019.
//

import Foundation
import AppStoreManagerAuthorization

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
        do {
            let payload = AppStoreConnectPayload(issuerIdentifier: data.issuerId)
            let signer = AppStoreConnectSigner(keyIdentifier: data.keyId, payload: payload)
            let token = try signer.generateJWTToken(usingPrivateKey: data.privateKey)
            return .success(token)
        } catch {
            return .failure(.init(message: "Could not generate JWT token"))
        }
    }
}

extension AuthorizationService {

    struct Error: Swift.Error {
        /// The message do not have any private data
        let message: String
    }
}
