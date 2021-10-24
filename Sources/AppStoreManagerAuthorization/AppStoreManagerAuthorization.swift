//
//  AppStoreConnectSigner.swift
//  
//
//  Created by Mateusz Kuznik on 16/11/2019.
//

import Foundation
import SwiftJWT
import CryptoKit

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
    public func generateJWTToken(usingPrivateKey privateKey: Data) throws -> String {
        let header = Header(kid: keyIdentifier)
        var jwt = JWT(header: header, claims: createPayload())
        let signer = JWTSigner.es256(privateKey: privateKey)
        let signedJWT = try jwt.sign(using: signer)
        return signedJWT
    }

    /// Creates the instance of a `Claims` required by the `SwiftJWT` framework.
    ///
    /// The [Apple documentation](https://developer.apple.com/documentation/appstoreconnectapi/generating_tokens_for_api_requests) specifies the `aud` parameter as a `String` but the `ClaimsStandardJWT` gets an array. From the [JWT documentation](https://tools.ietf.org/html/rfc7519#section-4.1.3):
    /// ```
    /// In the special case when the JWT has one audience,
    /// the "aud" value MAY be a single case-sensitive
    /// string containing a StringOrURI value.
    /// ```
    ///
    /// Hopefully this will works 🙏
    private func createPayload() -> ClaimsAppStoreJWT {
        ClaimsAppStoreJWT(
            iss: payload.issuerIdentifier,
            aud: payload.audience,
            exp: payload.expirationTime)
    }
}

private struct ClaimsAppStoreJWT: Claims {
    let iss: String
    let aud: String
    let exp: Date

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
    fileprivate var expirationTime: Date {
        return Date(timeIntervalSinceNow: 60 * 4)
    }

    /// It is encoded as a *aud* value in the TWT payload
    internal let audience: String = "appstoreconnect-v1"

    public init(issuerIdentifier: String) {

        self.issuerIdentifier = issuerIdentifier
    }
}
