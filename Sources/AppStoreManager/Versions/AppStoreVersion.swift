//
//  File.swift
//  
//
//  Created by Mateusz Kuznik on 24/06/2021.
//

import Foundation

public struct AppStoreVersion: Decodable {

    public let platform: BundleIdPlatform
    public let appStoreState: State
    public let versionString: String
    public let createdDate: String
}

extension AppStoreVersion {

    public enum State: String, Decodable {
        case DEVELOPER_REMOVED_FROM_SALE = "DEVELOPER_REMOVED_FROM_SALE"
        case DEVELOPER_REJECTED = "DEVELOPER_REJECTED"
        case IN_REVIEW = "IN_REVIEW"
        case INVALID_BINARY = "INVALID_BINARY"
        case METADATA_REJECTED = "METADATA_REJECTED"
        case PENDING_APPLE_RELEASE = "PENDING_APPLE_RELEASE"
        case PENDING_CONTRACT = "PENDING_CONTRACT"
        case PENDING_DEVELOPER_RELEASE = "PENDING_DEVELOPER_RELEASE"
        case PREPARE_FOR_SUBMISSION = "PREPARE_FOR_SUBMISSION"
        case PREORDER_READY_FOR_SALE = "PREORDER_READY_FOR_SALE"
        case PROCESSING_FOR_APP_STORE = "PROCESSING_FOR_APP_STORE"
        case READY_FOR_SALE = "READY_FOR_SALE"
        case REJECTED = "REJECTED"
        case REMOVED_FROM_SALE = "REMOVED_FROM_SALE"
        case WAITING_FOR_EXPORT_COMPLIANCE = "WAITING_FOR_EXPORT_COMPLIANCE"
        case WAITING_FOR_REVIEW = "WAITING_FOR_REVIEW"
        case REPLACED_WITH_NEW_VERSION = "REPLACED_WITH_NEW_VERSION"
    }
}
