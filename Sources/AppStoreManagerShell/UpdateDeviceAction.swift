//
//  UpdateDeviceAction.swift
//  
//
//  Created by Mateusz Kuznik on 06/12/2019.
//

import Foundation
import AppStoreManager
import os
import Combine

struct UpdateDeviceAction {

    private let commandLineService: CommandLineService
    private let authorizationService: AuthorizationService

    init(
        commandLineService: CommandLineService,
        authorizationService: AuthorizationService) {

        self.commandLineService = commandLineService
        self.authorizationService = authorizationService
    }

    private func value(for parameter: UpdateDeviceParameter) -> Result<String, Self.Error> {
        return commandLineService
            .value(for: parameter)
            .mapError { (error) -> Error in
                return Error(message: error.message)
            }
    }

    func perform() {
        let deviceName = value(for: .name)
            .map { (name) -> UpdateDevice in
                UpdateDevice(name: name)
            }
        let deviceIdentifier = value(for: .deviceIdentifier)

        deviceName
            .concatenate(deviceIdentifier, mapError: mapError)
            .map { ($0.success, $0.other) }
            .execute(onSuccess: update, onFailure: handle)


    }

    private func update(updateDevice: UpdateDevice, forDeviceWithUDID udid: String) {
        let authorizationToken = getAuthorizationToken()
        let client = Client(authorizationTokenProvider: { authorizationToken })
        let request = AllDevicesRequest(filters: Set(arrayLiteral: .udid(udid)), limit: 1)

        let cancelable = client
            .perform(request)
            .mapError { Error(message: "\($0)") }
            .flatMap { (response) -> AnyPublisher<Response<Device>, Error> in

                if let device = response.data.first,
                    let updateRequest = try? UpdateDeviceRequest(for: updateDevice, withIdentifier: device.identifier) {


                    return self.update(request: updateRequest, using: client)
                } else {
                    return Fail(error: Error(message: "Device with given udid does not exist")).eraseToAnyPublisher()
                }
            }
            .sink(
                receiveCompletion: { (completion) in
                    switch completion {
                    case .finished:
                        exit(0) //TODO: no response (empty chain) will also success :(
                    case let .failure(error):
                        let stringError = "\(error)"
                        os_log("%@", log: Logger.logger, type: .error, stringError)
                        exit(10)
                    }
                },
                receiveValue: { (_) in })

        RunLoop.main.run()
        withExtendedLifetime(cancelable, {})
    }

    private func update(request: UpdateDeviceRequest, using client: Client) -> AnyPublisher<Response<Device>, Self.Error> {

        return client
            .perform(request)
            .mapError { Error(message: "\($0)") }
            .eraseToAnyPublisher()
    }

    private func getAuthorizationToken() -> String {
        let authorizationTokenResult = authorizationService.authorizationToken()

        switch authorizationTokenResult {
        case let .success(token):
            return token
        case let .failure(error):
            handle(error)
            exit(1)
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

extension UpdateDeviceAction {

    struct Error: Swift.Error {
        /// The message do not have any private data
        let message: String
    }
}

extension UpdateDeviceAction.Error: ExpressibleByStringLiteral, ExpressibleByStringInterpolation {

    init(stringLiteral: String) {
        self = Self(message: stringLiteral)
    }
}
