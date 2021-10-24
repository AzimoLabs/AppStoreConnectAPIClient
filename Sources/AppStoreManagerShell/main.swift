import Foundation
import AppStoreManagerAuthorization
import AppStoreManager
import ArgumentParser
import Combine
import os

extension BundleIdPlatform: ExpressibleByArgument {}

struct Logger {
    static let logger = OSLog(subsystem: "com.azimo.appStoreManager", category: "shell")
}

protocol AuthorizedAction {
    var keyId: String { get }
    var issuerId: String { get }
    var privateKey: String { get }
}

func getAuthorizationToken(action: AuthorizedAction) -> String {
    let privateKey: String
    if action.privateKey.hasPrefix("-----BEGIN") == false,
       action.privateKey.contains("\\n") {

        privateKey = """
        -----BEGIN PRIVATE KEY-----
        \(action.privateKey.replacingOccurrences(of: "\\n", with: "\n"))
        -----END PRIVATE KEY-----
        """
    } else {
        privateKey = action.privateKey
    }

    let authorizationService = AuthorizationService(
        keyId: action.keyId,
        issuerId: action.issuerId,
        privateKey: privateKey)
    let authorizationTokenResult = authorizationService.authorizationToken()

    switch authorizationTokenResult {
    case let .success(token):
        return token
    case let .failure(error):
        os_log("Could not generate JWT token: \n%{public}@", log: Logger.logger, type: .error, error.message)
        _exit(ExitCode.failure.rawValue)
    }
}

struct AppStoreManager: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "appStore",
        abstract: "An Appstore REST API",
        version: "0.0.1",
        subcommands: [
            RegisterDevice.self,
            Apps.self,
            Builds.self,
            LastBuildNumber.self,
            UpdateWhatIsNew.self,
            CreateVersionAction.self
        ])
}

AppStoreManager.main()
