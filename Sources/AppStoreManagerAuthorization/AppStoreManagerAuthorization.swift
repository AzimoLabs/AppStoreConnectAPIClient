//
//  AppStoreConnectSigner.swift
//  
//
//  Created by Mateusz Kuznik on 16/11/2019.
//

import Foundation

/// Helper object which generate the JWT token to authorize requests to the _AppStoreConnect API_.
///
/// See [Apple documentation](https://developer.apple.com/documentation/appstoreconnectapi/generating_tokens_for_api_requests) for more details.
public struct AppStoreConnectSigner {

    /// Your private key ID from App Store Connect (Ex: 2X9R4HXF34)
    ///https://developer.apple.com/documentation/appstoreconnectapi/generating_tokens_for_api_requests
    public let keyIdentifier: String
    /// The JWT payload required to create token.
    /// Each time the **generateJWTToken(usingPrivateKey:)** function is called the **payload** object is used to create required object.
    public let payload: AppStoreConnectPayload

    ///
    /// - Parameters:
    ///   - keyIdentifier: Your private key ID from App Store Connect (Ex: 2X9R4HXF34)
    ///   - payload: The JWT payload required to create token.
    public init(
        keyIdentifier: String,
        payload: AppStoreConnectPayload) {

        self.keyIdentifier = keyIdentifier
        self.payload = payload
    }

    /// Generates a JWT token which can be used to authorise requests to the _AppStoreConnect API_.
    ///
    /// Each time this function is called the new token is created with expiration date set to 4 minutes (the Date(timeIntervalSinceNow:) is used).
    ///
    /// Add a generated token as a header to all requests like:
    /// ```
    /// Authorization: Bearer \(authorizationToken)
    /// ```
    ///
    /// - Parameter privateKey: The private key used to sign the token.
    /// - Returns: The signed token to use to authorize requests.
    public func generateJWTToken(usingPrivateKey privateKey: String) throws -> String {
        let generator = JWTGenerator(keyIdentifier: keyIdentifier, payload: payload)
        return try generator.token(withPrivateKey: privateKey)
    }
}
/// The payload required to create a JWT token.
///
/// Only the **issuerIdentifier** is required.
/// The expiration date is always created based on current date and is 4 minutes.
/// The **audience** is hardcoded to `appstoreconnect-v1`
public struct AppStoreConnectPayload {

    /// Your issuer ID from the API Keys page in App Store Connect (Ex: 57246542-96fe-1a63-e053-0824d011072a)
    /// It is encoded as a *iss* value in the TWT payload
    public let issuerIdentifier: String

    /// The token's expiration time; tokens that expire more than 4 minutes in the future are not valid (Ex: 1528408800)
    /// It is encoded as a *exp* value in the TWT payload
    internal var expirationTime: Date {
        return Date(timeIntervalSinceNow: 60 * 4)
    }

    /// It is encoded as a *aud* value in the TWT payload
    internal let audience: String = "appstoreconnect-v1"

    public init(issuerIdentifier: String) {

        self.issuerIdentifier = issuerIdentifier
    }
}
