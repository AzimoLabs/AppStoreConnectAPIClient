//
//  BundleIdPlatform.swift
//  
//
//  Created by Mateusz Kuznik on 20/11/2019.
//

import Foundation

///https://developer.apple.com/documentation/appstoreconnectapi/bundleidplatform
public enum BundleIdPlatform: String, Codable, CaseIterable {
    case iOS = "IOS"
    case macOS = "MAC_OS"
}
