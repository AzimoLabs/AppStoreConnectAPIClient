//
//  File.swift
//  
//
//  Created by Mateusz Kuznik on 16/06/2021.
//

import Foundation

/// The structure representing an app returned by `AppStoreConnect API`
///
/// https://developer.apple.com/documentation/appstoreconnectapi/app
public struct App: Decodable {
    public let id: String
}
