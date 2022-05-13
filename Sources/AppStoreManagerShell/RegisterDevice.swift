//
//  RegisterDevice.swift
//  
//
//  Created by Mateusz Kuznik on 29/11/2019.
//

import Foundation
import AppStoreManager
import ArgumentParser

struct RegisterDevice: AsyncParsableCommand {

    @Option(
        help: ArgumentHelp(
            "The name of the device to register"))
    var deviceName: String

    @Option(
        help: ArgumentHelp(
            "The identifier of the device to register"))
    var deviceId: String

    @Option(
        help: ArgumentHelp(
            "The platform of the device to register"))
    var platform: BundleIdPlatform

    @Option(
        help: ArgumentHelp(
            "The JWT token",
            discussion: "To generate JWT token use the authorise "))
    var jwtToken: String


    func run() async throws {
        let newDevice = NewDevice(
            name: deviceName,
            platform: platform,
            identifier: deviceId)

        let newDeviceRequest = try NewDeviceRequest(for: newDevice)

        await register(newDeviceRequest)
    }

    private func register(_ request: NewDeviceRequest) async {
        let client = Client(authorizationTokenProvider: { jwtToken })
        do {
            let response: Device = try await client.perform(request).get().data
            Self.exit(withError: CleanExit.message("New device registered: id: \(response.identifier), UUID:\(response.attributes.udid ?? "unknown")"))
        } catch {
            Self.exit(withError: ValidationError("\(error)"))
        }
    }
}
