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

struct CreateVersionAction: ParsableCommand {

    static var configuration = CommandConfiguration(
        commandName: "create-version",
        abstract: "Create a new app version")

    @Option(
        help: ArgumentHelp(
            "The JWT token",
            discussion: "To generate JWT token use the authorise ",
            shouldDisplay: true))
    var jwtToken: String

    @Option(
        help: ArgumentHelp(
            "The app version to create",
            shouldDisplay: true))
    var appVersion: String

    @Option(
        help: ArgumentHelp(
            "The app identifier",
            shouldDisplay: true))
    var appIdentifier: String

    @Option(
        help: ArgumentHelp(
            "Platform for which the version should be created",
            shouldDisplay: true))
    var platform: BundleIdPlatform = .iOS

    func run() throws {

        let client = Client(authorizationTokenProvider: { jwtToken })
        let update = CreateVersion(
            attributes: .init(platform: platform, versionString: appVersion),
            app: .init(id: appIdentifier))
        let request = try CreateVersionRequest(for: update)

        let semaphore = DispatchSemaphore(value: 0)
        let cancelable = client.perform(request)
            .sink(
                receiveCompletion: { (completion) in
                    switch completion {
                    case .finished:
                        Self.exit(withError: CleanExit.message(""))
                    case let .failure(error):
                        Self.exit(withError: ValidationError("\(error)"))
                    }
                },
                receiveValue: { (app) in
                    Self.exit(withError: CleanExit.message("\(app.data)"))
                })
        _ = semaphore.wait(timeout: .now() + .seconds(10))
        withExtendedLifetime(cancelable, {})
        Self.exit(withError: ValidationError("The request has timed out"))
    }
}
