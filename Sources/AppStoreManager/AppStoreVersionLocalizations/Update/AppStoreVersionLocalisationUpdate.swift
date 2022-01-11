//
//  AppStoreVersionLocalisationUpdate.swift
//  
//
//  Created by Mateusz Kuznik on 25/06/2021.
//

import Foundation

///https://developer.apple.com/documentation/appstoreconnectapi/appstoreversionlocalizationupdaterequest/data
public struct AppStoreVersionLocalisationUpdate: Encodable {
    public let attributes: Attributes
    public let id: String
    let type = "appStoreVersionLocalizations"

    public init(attributes: Attributes, id: String) {
        self.attributes = attributes
        self.id = id
    }
}

extension AppStoreVersionLocalisationUpdate {

    ///https://developer.apple.com/documentation/appstoreconnectapi/appstoreversionlocalizationupdaterequest/data/attributes
    public struct Attributes: Encodable {
        let whatsNew: String?

        public init(whatsNew: String?) {
            self.whatsNew = whatsNew
        }
    }
}
