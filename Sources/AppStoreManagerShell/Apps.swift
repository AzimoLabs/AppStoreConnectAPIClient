//
//  File.swift
//  
//
//  Created by Mateusz Kuznik on 16/06/2021.
//

import Foundation
import ArgumentParser
import AppStoreManager
import os

struct Apps: ParsableCommand, AuthorizedAction {

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

    @Option(
        help: ArgumentHelp(
            "The apps limit",
            shouldDisplay: true))
    var limit: Int = 10

    func run() throws {
        let authorizationToken = getAuthorizationToken(action: self)
        let client = Client(authorizationTokenProvider: { authorizationToken })

        let cancelable = client.perform(AllAppsRequest(limit: limit))
            .sink(
                receiveCompletion: { (completion) in
                    switch completion {
                    case .finished:
                        _exit(ExitCode.success.rawValue) //TODO: no response (empty chain) will also success :(
                    case let .failure(error):
                        let stringError = "\(error)"
                        os_log("%@", log: Logger.logger, type: .error, stringError)
                        _exit(ExitCode.failure.rawValue)
                    }
                },
                receiveValue: { (apps) in })

        RunLoop.main.run()
        withExtendedLifetime(cancelable, {})
    }
}
