//
//  File.swift
//  
//
//  Created by Mateusz Kuznik on 24/06/2021.
//

import Foundation
import AppStoreManager
import ArgumentParser
import os
import Combine

struct UpdateWhatIsNew: ParsableCommand, AuthorizedAction {

    static var configuration = CommandConfiguration(
        abstract: "This command will get the recent version in the status `Ready to sell` and copy paste the `What is new` section to the version in the `Prepare for submission` status",
        discussion: """
                    This command assumes that the version in the status `Prepare for submission` is already created. If there is no version in `Prepare for submission` the error is thrown.
                    Newly added languages are ignored and need to be updated manually as for now.
                    The version in the status `Prepare for submission` for a given locale will be ignored if message is already set.
                    """)

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

    @Option(
        help: ArgumentHelp(
            "The application identifeir",
            shouldDisplay: true))
    var appIdentifier: String

    func run() throws {
        let authorizationToken = getAuthorizationToken(action: self)
        let client = Client(authorizationTokenProvider: { authorizationToken })
        let semaphore = DispatchSemaphore(value: 0)

        //Get last two. The second one should have status ready for sell. We will take what is new from this one and paste them to the new version
        let getLocalisations = GetAppStoreVersionsRequests(identifier: appIdentifier, limit: 2)

        let cancelable = client
            .perform(getLocalisations)
            .flatMap { response -> AnyPublisher<([GetAppStoreVersionLocalisation.ResponseObject], [GetAppStoreVersionLocalisation.ResponseObject]), Client.Error> in

                os_log("GetAppStoreVersionsRequests finished: %{public}@", log: Logger.logger, type: .info, response.data)
                let readyForSale = self.findFirstItem(in: response.data, with: .READY_FOR_SALE)
                let getLocalised = self.getLocalisations(for: readyForSale, client: client)

                let prepareForSubmission = self.findFirstItem(in: response.data, with: .PREPARE_FOR_SUBMISSION)
                let getToLocalise = self.getLocalisations(for: prepareForSubmission, client: client)

                return getLocalised.combineLatest(getToLocalise) { (localised, toLocalise) in
                    (localised.data, toLocalise.data)
                }
                .eraseToAnyPublisher()
            }

            .map { (localised, toLocalise) -> [(String, GetAppStoreVersionLocalisation.ResponseObject)] in

                //connect the localised message from the previous version with new one
                let itemsWithLocalisedVersion = toLocalise.compactMap { toLocaliseItem -> (String, GetAppStoreVersionLocalisation.ResponseObject)? in
                    guard
                        let localisedItem = localised.first(where: { $0.attributes.locale == toLocaliseItem.attributes.locale }),
                        let whatIsNew = localisedItem.attributes.whatsNew
                    else {
                        os_log("There is no localised version for %{public}@", log: Logger.logger, type: .fault, toLocaliseItem.attributes.locale)
                        //ignore if new language
                        return nil
                    }
                    guard toLocaliseItem.attributes.whatsNew == nil else {
                        os_log("The localised version for %{public}@ is already set. Skipping.", log: Logger.logger, type: .info, toLocaliseItem.attributes.locale)
                        return nil
                    }
                    return (whatIsNew, toLocaliseItem)
                }

                return itemsWithLocalisedVersion
            }
            .flatMap { (itemsWithLocalisedVersion) -> AnyPublisher<[AnyPublisher<Response<AppStoreVersionLocalizationUpdateRequest.ResponseObject>, Client.Error>.Output], AnyPublisher<Response<AppStoreVersionLocalizationUpdateRequest.ResponseObject>, Client.Error>.Failure> in

                //map (String, GetAppStoreVersionLocalisation.ResponseObject) to the request object
                let updatesRequests = itemsWithLocalisedVersion
                    .map { (whatIsNew, toLocaliseItem) in
                        AppStoreVersionLocalizationUpdate(
                            attributes: .init(whatsNew: whatIsNew),
                            id: toLocaliseItem.id)
                    }
                    .compactMap { localisation -> AnyPublisher<Response<AppStoreVersionLocalizationUpdateRequest.ResponseObject>, Client.Error>? in
                        do {
                            let updateRequest = try AppStoreVersionLocalizationUpdateRequest(withIdentifier: localisation.id, for: localisation)
                            return client.perform(updateRequest)
                        } catch {
                            let stringError = "\(error)"
                            os_log("Could not create request object. %{public}@", log: Logger.logger, type: .fault, stringError)
                            return nil
                        }
                    }
                os_log("Items to update: %{public}i", log: Logger.logger, type: .info, updatesRequests.count)

                //perform each request
                return Publishers.MergeMany(updatesRequests).collect().eraseToAnyPublisher()
            }
            .sink(
                receiveCompletion: { (completion) in
                    switch completion {
                    case .finished:
                        break
                    case let .failure(error):
                        let stringError = "\(error)"
                        os_log("%{public}@", log: Logger.logger, type: .error, stringError)
                        _exit(ExitCode.failure.rawValue)
                    }
                },
                receiveValue: { (_) in
                    semaphore.signal()
                })
        _ = semaphore.wait(timeout: .now() + .seconds(10))
        withExtendedLifetime(cancelable, {})
    }

    private func findFirstItem(in response: GetAppStoreVersionsRequests.Response, with state: AppStoreVersion.State) -> GetAppStoreVersionsRequests.ResponseObject {
        let readyForSell = response.first { item in
            item.attributes.appStoreState == state
        }

        if let item = readyForSell {
            return item
        } else {
            os_log("There is no %{public}@ version 😔", log: Logger.logger, type: .error, state.rawValue)
            _exit(ExitCode.failure.rawValue)
        }
    }

    private func getLocalisations(for item: GetAppStoreVersionsRequests.ResponseObject, client: Client) -> AnyPublisher<Response<[GetAppStoreVersionLocalisation.ResponseObject]>, Client.Error> {

        let get = GetAppStoreVersionLocalisation(identifier: item.id)
        return client.perform(get)
    }
}
