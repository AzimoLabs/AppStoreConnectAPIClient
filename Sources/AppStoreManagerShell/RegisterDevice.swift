//
//  RegisterDevice.swift
//  
//
//  Created by Mateusz Kuznik on 29/11/2019.
//

import Foundation
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
            "The JWT token",
            discussion: "To generate JWT token use the authorise ",
            shouldDisplay: true))
    var jwtToken: String


    func run() throws {
        let newDevice = NewDevice(
            name: deviceName,
            platform: platform,
            identifier: deviceId)

        let newDeviceRequest = try NewDeviceRequest(for: newDevice)

        register(newDeviceRequest)
    }

    private func register(_ request: NewDeviceRequest) {
        let client = Client(authorizationTokenProvider: { jwtToken })

        let semaphore = DispatchSemaphore(value: 0)
        Task {
            do {
                let response: Device = try await client.perform(request).get().data
                Self.exit(withError: CleanExit.message("New device registered: id: \(response.identifier), UUID:\(response.attributes.udid ?? "unknown")"))
            } catch {
                Self.exit(withError: ValidationError("\(error)"))
            }
        }
        _ = semaphore.wait(timeout: .now() + .seconds(10))
        Self.exit(withError: ValidationError("The request has timed out"))
    }
}
