//
//  File.swift
//  
//
//  Created by Mateusz Kuznik on 24/06/2021.
//

import Foundation
import AppStoreManager
import ArgumentParser

struct UpdateWhatIsNew: AsyncParsableCommand {

    static var configuration = CommandConfiguration(
        abstract: "This command will get the recent version in the status `Ready to sell` and copy paste the `What is new` section to the version in the `Prepare for submission` status",
        discussion: """
                    This command assumes that the version in the status `Prepare for submission` is already created. If there is no version in `Prepare for submission` the error is thrown.
                    Newly added languages are ignored and need to be updated manually as for now.
                    The version in the status `Prepare for submission` for a given locale will be ignored if message is already set.
                    """)

    @Option(
        help: ArgumentHelp(
            "The JWT token",
            discussion: "To generate JWT token use the authorise "))
    var jwtToken: String

    @Option(
        help: ArgumentHelp(
            "The application identifier"))
    var appIdentifier: String

    private func localisedData(with client: Client) async throws -> (localised: [GetAppStoreVersionLocalisation.ResponseObject], toLocalise: [GetAppStoreVersionLocalisation.ResponseObject] ) {

        let getLocalisationsRequest = GetAppStoreVersionsRequests(identifier: appIdentifier, limit: 2)
        let response = try await client.perform(getLocalisationsRequest).get()

        let readyForSale = try findFirstItem(in: response.data, with: .READY_FOR_SALE)
        let localised = try await getLocalisations(for: readyForSale, client: client).get().data

        let prepareForSubmission = try findFirstItem(in: response.data, with: .PREPARE_FOR_SUBMISSION)
        let toLocalise = try await getLocalisations(for: prepareForSubmission, client: client).get().data
    
        return (localised, toLocalise)
    }

    private func groupLocalisations(localised: [GetAppStoreVersionLocalisation.ResponseObject], toLocalise: [GetAppStoreVersionLocalisation.ResponseObject]) -> [(String, GetAppStoreVersionLocalisation.ResponseObject)] {

        let itemsWithLocalisedVersion = toLocalise
            .compactMap { toLocaliseItem -> (String, GetAppStoreVersionLocalisation.ResponseObject)? in
                guard
                    let localisedItem = localised.first(where: { $0.attributes.locale == toLocaliseItem.attributes.locale }),
                    let whatIsNewOfPreviousVersion = localisedItem.attributes.whatsNew
                else {
                    print("There is no localised version for \(toLocaliseItem.attributes.locale). Ignoring...")
                    return nil
                }
                guard toLocaliseItem.attributes.whatsNew == nil else {
                    print("The localised version for \(toLocaliseItem.attributes.locale) is already set. Skipping...")
                    return nil
                }
                return (whatIsNewOfPreviousVersion, toLocaliseItem)
            }

        return itemsWithLocalisedVersion
    }

    private func createUpdateLocalisationsRequests(from itemsWithLocalisedVersion: [(String, GetAppStoreVersionLocalisation.ResponseObject)]) -> [AppStoreVersionLocalisationUpdateRequest] {

        return itemsWithLocalisedVersion
            .map { (whatIsNew, toLocaliseItem) in
                AppStoreVersionLocalisationUpdate(
                    attributes: .init(whatsNew: whatIsNew),
                    id: toLocaliseItem.id)
            }
            .compactMap { localisation -> AppStoreVersionLocalisationUpdateRequest? in
                do {
                    return try AppStoreVersionLocalisationUpdateRequest(withIdentifier: localisation.id, for: localisation)
                } catch {
                    let stringError = "\(error)"

                    print("Could not create request object. \(stringError)")
                    return nil
                }
            }
    }

    func run() async throws {
        let client = Client(authorizationTokenProvider: { jwtToken })

        let data: (localised: [GetAppStoreVersionLocalisation.ResponseObject], toLocalise: [GetAppStoreVersionLocalisation.ResponseObject])
        do {
            data = try await localisedData(with: client)
        } catch let error as ValidationError {
            Self.exit(withError: error)
        } catch {
            Self.exit(withError: ValidationError("\(error)"))
        }

        let itemsWithLocalisedVersion = groupLocalisations(localised: data.localised, toLocalise: data.toLocalise)
        let updateRequests = createUpdateLocalisationsRequests(from: itemsWithLocalisedVersion)
        for request in updateRequests {
            do {
                _ = try await client.perform(request).get()
            } catch {
                print("Could not update the What is new section for: \(request.id). \n\(error) \nTrying next... ")
            }
        }
        Self.exit(withError: CleanExit.message(""))
    }

    private func findFirstItem(in response: GetAppStoreVersionsRequests.Response, with state: AppStoreVersion.State) throws -> GetAppStoreVersionsRequests.ResponseObject {
        let readyForSell = response.first { item in
            item.attributes.appStoreState == state
        }

        if let item = readyForSell {
            return item
        } else {
            throw ValidationError("There is no \(state.rawValue) version 😔")
        }
    }

    private func getLocalisations(for item: GetAppStoreVersionsRequests.ResponseObject, client: Client) async -> Result<Response<[GetAppStoreVersionLocalisation.ResponseObject]>, Client.Error> {

        let get = GetAppStoreVersionLocalisation(identifier: item.id)
        return await client.perform(get)
    }
}
