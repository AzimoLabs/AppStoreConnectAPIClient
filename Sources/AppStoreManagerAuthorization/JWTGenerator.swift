//
//  JWTGenerator.swift
//  
//
//  Created by Kamil Strzelecki on 17/05/2022.
//  Copyright © 2022 Kamil Strzelecki. All rights reserved.
//

import CryptoKit
import Foundation


internal struct JWTGenerator {
    
    internal let keyIdentifier: String
    internal let payload: AppStoreConnectPayload
    
    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        return encoder
    }()
    
    internal func token(withPrivateKey privateKey: String) throws -> String {
        let header = try headerBytes()
        let payload = try payloadBytes()
        let period = Array(Character(".").utf8)
    
        let dataToSign = header + period + payload
        let signatureData = try sign(dataToSign, withPrivateKey: privateKey)
        
        let signedData = Data(dataToSign + period + signatureData)
        return String(decoding: signedData, as: UTF8.self)
    }
    
    private func sign(_ dataToSign: [UInt8], withPrivateKey privateKey: String) throws -> [UInt8] {
        let privateKey = try P256.Signing.PrivateKey(pemRepresentation: privateKey)
        let signature = try privateKey.signature(for: dataToSign)
        return Array(signature.rawRepresentation.base64URLEncodedData())
    }
    
    private func headerBytes() throws -> [UInt8] {
        let header = Header(kid: keyIdentifier)
        let data = try encoder.encode(header)
        return Array(data.base64URLEncodedData())
    }
    
    private func payloadBytes() throws -> [UInt8] {
        let payload = Payload(payload)
        let data = try encoder.encode(payload)
        return Array(data.base64URLEncodedData())
    }
}


extension JWTGenerator {
    
    fileprivate struct Header: Encodable {
        
        fileprivate let alg = "ES256"
        fileprivate let typ = "JWT"
        fileprivate let kid: String
    }
}


extension JWTGenerator {
    
    fileprivate struct Payload: Encodable {
        
        fileprivate let iss: String
        fileprivate let aud: String
        fileprivate let exp: Date
        
        fileprivate init(_ payload: AppStoreConnectPayload) {
            self.iss = payload.issuerIdentifier
            self.aud = payload.audience
            self.exp = payload.expirationTime
        }
    }
}


extension Data {
    
    /// Converts data to a base64-url encoded data.
    ///
    /// https://tools.ietf.org/html/rfc4648#page-7
    internal func base64URLEncodedData() -> Data {
        var data = base64EncodedData()
        
        for (index, byte) in data.enumerated() {
            switch byte {
            case 0x2B:
                data[index] = 0x2D
            case 0x2F:
                data[index] = 0x5F
            default:
                continue
            }
        }
        
        return data.split(separator: 0x3D)
            .first ?? Data()
    }
}
