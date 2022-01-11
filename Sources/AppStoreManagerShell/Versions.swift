//
//  Versions.swift
//  
//
//  Created by Mateusz Kuznik on 24/06/2021.
//

import Foundation
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

        let request: CreateVersionRequest
        do {
            request = try CreateVersionRequest(for: update)
        } catch {
            Self.exit(withError: ValidationError("Could not create request object. \(error)"))
        }

        let semaphore = DispatchSemaphore(value: 0)
        Task {
            do {
                let response = try await client.perform(request).get().data
                Self.exit(withError: CleanExit.message("Created: \(response.attributes.versionString)"))
            } catch {
                Self.exit(withError: ValidationError("\(error)"))
            }
        }
        _ = semaphore.wait(timeout: .now() + .seconds(10))
        Self.exit(withError: ValidationError("The request has timed out"))
    }
}
