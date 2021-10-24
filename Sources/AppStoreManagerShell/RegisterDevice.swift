//
//  RegisterDevice.swift
//  
//
//  Created by Mateusz Kuznik on 29/11/2019.
//

import Foundation
import os
import AppStoreManager
import ArgumentParser

struct RegisterDevice: ParsableCommand {

    @Option(
        help: ArgumentHelp(
            "The name of the device to register",
            shouldDisplay: true))
    var deviceName: String

    @Option(
        help: ArgumentHelp(
            "The identifier of the device to register",
            
            shouldDisplay: true))
    var deviceId: String

    @Option(
        help: ArgumentHelp(
            "The platform of the device to register",
            shouldDisplay: true))
    var platform: BundleIdPlatform

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
        let newDevice = NewDevice(
            name: deviceName,
            platform: platform,
            identifier: deviceId)

        let newDeviceRequest = try NewDeviceRequest(for: newDevice)

        register(newDeviceRequest)
    }

    private func register(_ request: NewDeviceRequest) {
        let authorizationToken = getAuthorizationToken()
        let client = Client(authorizationTokenProvider: { authorizationToken })

        _ = client
            .perform(request)
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
                receiveValue: { (_) in })

        RunLoop.main.run()
    }

    private func getAuthorizationToken() -> String {
        let authorizationService = AuthorizationService(keyId: keyId, issuerId: issuerId, privateKey: privateKey)
        let authorizationTokenResult = authorizationService.authorizationToken()

        switch authorizationTokenResult {
        case let .success(token):
            return token
        case let .failure(error):
            handle(error)
            _exit(ExitCode.failure.rawValue)
        }
    }

    private func handle(_ error: AuthorizationService.Error) {
        os_log("Could not generate JWT token: \n%{public}@", log: Logger.logger, type: .error, error.message)
    }

    private func handle(_ error: Self.Error) {
        os_log("%{public}@", log: Logger.logger, type: .error, error.message)
    }

    private func mapError<Enything>(error: Result<Enything, Self.Error>.ConcatenatedError<Self.Error>) -> Self.Error {

        switch error {
        case let .both(payloadError, keyIdentifierError):
            return .init(message: "\(payloadError.message)\n\(keyIdentifierError.message)")
        case let .failure(error),
             let .other(error):
            return error
        }
    }
}

extension RegisterDevice {

    struct Error: Swift.Error {
        /// The message do not have any private data
        let message: String
    }
}

extension RegisterDevice.Error: ExpressibleByStringLiteral, ExpressibleByStringInterpolation {

    init(stringLiteral: String) {
        self = Self(message: stringLiteral)
    }
}
