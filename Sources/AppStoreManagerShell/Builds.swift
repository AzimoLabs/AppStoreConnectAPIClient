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

struct Builds: ParsableCommand, AuthorizedAction {
    
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

    @Option(
        help: ArgumentHelp(
            "The identifier of the app for which the builds should be returned",
            shouldDisplay: true))
    var appIdentifier: String?

    func run() throws {
        let authorizationToken = getAuthorizationToken(action: self)
        let client = Client(authorizationTokenProvider: { authorizationToken })

        let filters = appIdentifier.map { (identifier) -> Set<AllBuildsRequest.Filter> in
            [.appIdentifier(identifier)]
        }
        let cancelable = client.perform(AllBuildsRequest(filters: filters ?? [], limit: limit))
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
                receiveValue: { (builds) in })

        RunLoop.main.run()
        withExtendedLifetime(cancelable, {})
    }
}

struct LastBuildNumber: ParsableCommand, AuthorizedAction {

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
            "The identifier of the app for which the builds should be returned",
            shouldDisplay: true))
    var appIdentifier: String

    func run() throws {
        let authorizationToken = getAuthorizationToken(action: self)
        let client = Client(authorizationTokenProvider: { authorizationToken })
        let semaphore = DispatchSemaphore(value: 0)
        let cancelable = client.perform(AllBuildsRequest(filters: [.appIdentifier(appIdentifier)], limit: 1))
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
                receiveValue: { (builds) in
                    if let first = builds.data.first {
                        print(first.attributes.version)
                        semaphore.signal()
                    } else {
                        _exit(ExitCode.failure.rawValue)
                    }
                })
//        RunLoop.main.run()
        _ = semaphore.wait(timeout: .now() + .seconds(10))
        withExtendedLifetime(cancelable, {})
    }
}
