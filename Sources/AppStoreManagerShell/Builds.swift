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

struct Builds: ParsableCommand {

    @Option(
        help: ArgumentHelp(
            "The JWT token",
            discussion: "To generate JWT token use the authorise ",
            shouldDisplay: true))
    var jwtToken: String

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
        let client = Client(authorizationTokenProvider: { jwtToken })
        let filters = appIdentifier.map { (identifier) -> Set<AllBuildsRequest.Filter> in
            [.appIdentifier(identifier)]
        }
        let semaphore = DispatchSemaphore(value: 0)
        let cancelable = client.perform(AllBuildsRequest(filters: filters ?? [], limit: limit))
            .sink(
                receiveCompletion: { (completion) in
                    switch completion {
                    case .finished:
                        Self.exit(withError: CleanExit.message(""))
                    case let .failure(error):
                        Self.exit(withError: ValidationError("\(error)"))
                    }
                },
                receiveValue: { (builds) in
                    Self.exit(withError: CleanExit.message(""))
                    //do nothing as for know. Do we really need it in the shell?
                })
        _ = semaphore.wait(timeout: .now() + .seconds(10))
        withExtendedLifetime(cancelable, {})
        Self.exit(withError: ValidationError("The request has timed out"))
    }
}

struct LastBuildNumber: ParsableCommand {

    @Option(
        help: ArgumentHelp(
            "The JWT token",
            discussion: "To generate JWT token use the authorise ",
            shouldDisplay: true))
    var jwtToken: String

    @Option(
        help: ArgumentHelp(
            "The identifier of the app for which the builds should be returned",
            shouldDisplay: true))
    var appIdentifier: String

    func run() throws {
        let client = Client(authorizationTokenProvider: { jwtToken })
        let semaphore = DispatchSemaphore(value: 0)
        let cancelable = client.perform(AllBuildsRequest(filters: [.appIdentifier(appIdentifier)], limit: 1))
            .sink(
                receiveCompletion: { (completion) in
                    switch completion {
                    case .finished:
                        Self.exit(withError: CleanExit.message(""))
                    case let .failure(error):
                        Self.exit(withError: ValidationError("\(error)"))
                    }
                },
                receiveValue: { (builds) in
                    if let first = builds.data.first {
                        Self.exit(withError: CleanExit.message(first.attributes.version))
                    } else {
                        Self.exit(withError: ValidationError("The list of builds is empty"))
                    }
                })
        _ = semaphore.wait(timeout: .now() + .seconds(10))
        withExtendedLifetime(cancelable, {})
        Self.exit(withError: ValidationError("The request has timed out"))
    }
}
