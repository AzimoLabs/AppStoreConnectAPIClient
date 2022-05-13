//
//  File.swift
//  
//
//  Created by Mateusz Kuznik on 16/06/2021.
//

import Foundation
import ArgumentParser
import AppStoreManager

struct LastBuildNumber: AsyncParsableCommand {

    @Option(
        help: ArgumentHelp(
            "The JWT token",
            discussion: "To generate JWT token use the authorise"))
    var jwtToken: String

    @Option(
        help: ArgumentHelp(
            "The identifier of the app for which the builds should be returned"))
    var appIdentifier: String

    func run() async throws {
        let client = Client(authorizationTokenProvider: { jwtToken })
        let response = await client.perform(AllBuildsRequest(filters: [.appIdentifier(appIdentifier)], limit: 1))

        switch response {
        case let .success(builds):
            if let first = builds.data.first {
                Self.exit(withError: CleanExit.message(first.attributes.version))
            } else {
                Self.exit(withError: ValidationError("The list of builds is empty"))
            }
        case let .failure(error):
            Self.exit(withError: ValidationError("\(error)"))
        }
    }
}
