//
//  AppStoreVersionLocalization.swift
//  
//
//  Created by Mateusz Kuznik on 24/06/2021.
//

import Foundation


public struct AppStoreVersionLocalization {

    /// https://developer.apple.com/documentation/appstoreconnectapi/appstoreversionlocalization/attributes
    public struct Attributes: Codable {

        public let whatsNew: String?
        public let locale: String

        public init(whatsNew: String?, locale: Locale) {
            self.whatsNew = whatsNew
            self.locale = locale.identifier
        }
    }
}
