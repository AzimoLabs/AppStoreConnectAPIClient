//
//  File.swift
//  
//
//  Created by Mateusz Kuznik on 25/10/2021.
//

import Foundation
import AppStoreManager
import ArgumentParser

struct Authorise: ParsableCommand {

    static var configuration = CommandConfiguration(
        abstract: "Creates a JWT authorisation token required to authorise communication with the API")

    @Option(
        help: ArgumentHelp(
            "The key identifier",
            shouldDisplay: true))
    var keyId: String

    @Option(
        help: ArgumentHelp(
            "The issuer identifier",
            shouldDisplay: true))
    var issuerId: String

    @Option(
        help: ArgumentHelp(
            "The private key",
            shouldDisplay: true))
    var privateKey: String


    func run() throws {
        let privateKey: String
        if self.privateKey.hasPrefix("-----BEGIN") == false,
           self.privateKey.contains("\\n") {

            privateKey = """
            -----BEGIN PRIVATE KEY-----
            \(self.privateKey.replacingOccurrences(of: "\\n", with: "\n"))
            -----END PRIVATE KEY-----
            """
        } else {
            privateKey = self.privateKey
        }

        let authorizationService = AuthorizationService(
            keyId: keyId,
            issuerId: issuerId,
            privateKey: privateKey)
        let authorizationTokenResult = authorizationService.authorizationToken()

        switch authorizationTokenResult {
        case let .success(token):
            Self.exit(withError: CleanExit.message(token))
        case let .failure(error):
            Self.exit(withError: ValidationError("Could not generate JWT token: \(error)"))
        }
    }
}
