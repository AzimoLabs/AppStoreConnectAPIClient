import Foundation
import AppStoreManagerAuthorization
import AppStoreManager
import ArgumentParser

extension BundleIdPlatform: ExpressibleByArgument {}

struct AppStoreManager: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "appStore",
        abstract: "An Appstore REST API",
        version: "0.1.0",
        subcommands: [
            RegisterDevice.self,
            LastBuildNumber.self,
            UpdateWhatIsNew.self,
            CreateVersionAction.self,
            Authorise.self
        ])
}

AppStoreManager.main()
