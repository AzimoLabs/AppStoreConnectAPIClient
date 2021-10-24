//
//  CreateVersion.swift
//  
//
//  Created by Mateusz Kuznik on 24/06/2021.
//

import Foundation
import os
import ArgumentParser
import AppStoreManager

struct CreateVersionAction: ParsableCommand, AuthorizedAction {

    static var configuration = CommandConfiguration(
        commandName: "create-version",
        abstract: "Create a new app version")

    @Option(
        help: ArgumentHelp(
            "The app version to create",
            shouldDisplay: true))
    var appVersion: String

    @Option(
        help: ArgumentHelp(
            "The app identifier",
            shouldDisplay: true))
    var appId: String

    @Option(
        help: ArgumentHelp(
            "The app version",
            shouldDisplay: true))
    var platform: BundleIdPlatform = .iOS

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
        os_log("Run %{public}@", log: Logger.logger, type: .info, Self.configuration.commandName ?? "Unknown name")
        let authorizationToken = getAuthorizationToken(action: self)
        let client = Client(authorizationTokenProvider: { authorizationToken })
        let semaphore = DispatchSemaphore(value: 0)

        let update = CreateVersion(
            attributes: .init(platform: platform, versionString: appVersion),
            app: .init(id: appId))
        let request = try CreateVersionRequest(for: update)

        let cancelable = client.perform(request)
            .sink(
                receiveCompletion: { (completion) in
                    switch completion {
                    case .finished:
                        os_log("Finished %{public}@", log: Logger.logger, type: .info, Self.configuration.commandName ?? "Unknown name")
                    case let .failure(error):
                        let stringError = "\(error)"
                        os_log("%{public}@", log: Logger.logger, type: .error, stringError)
                        _exit(ExitCode.failure.rawValue)
                    }
                },
                receiveValue: { (app) in
                    print(app.data)
                    semaphore.signal()
                })
        _ = semaphore.wait(timeout: .now() + .seconds(10))
        withExtendedLifetime(cancelable, {})
    }
}
