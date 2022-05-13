//
//  Versions.swift
//  
//
//  Created by Mateusz Kuznik on 24/06/2021.
//

import Foundation
import ArgumentParser
import AppStoreManager

struct CreateVersionAction: AsyncParsableCommand {

    static var configuration = CommandConfiguration(
        commandName: "create-version",
        abstract: "Create a new app version")

    @Option(
        help: ArgumentHelp(
            "The JWT token",
            discussion: "To generate JWT token use the authorise "))
    var jwtToken: String

    @Option(
        help: ArgumentHelp(
            "The app version to create"))
    var appVersion: String

    @Option(
        help: ArgumentHelp(
            "The app identifier"))
    var appIdentifier: String

    @Option(
        help: ArgumentHelp(
            "Platform for which the version should be created"))
    var platform: BundleIdPlatform = .iOS

    func run() async throws {

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

        do {
            let response = try await client.perform(request).get().data
            Self.exit(withError: CleanExit.message("Created: \(response.attributes.versionString)"))
        } catch {
            Self.exit(withError: ValidationError("\(error)"))
        }
    }
}
