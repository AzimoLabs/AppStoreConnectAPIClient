//
//  File.swift
//  
//
//  Created by Mateusz Kuznik on 07/04/2020.
//

import Foundation

/// The structure representing a build returned by `AppStoreConnect API`
///
/// https://developer.apple.com/documentation/appstoreconnectapi/build
public struct Build: Decodable {

    public let identifier: String
    public let attributes: Attributes

    public init(
        identifier: String,
        attributes: Attributes) {

        self.identifier = identifier
        self.attributes = attributes
    }

    private enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case attributes
    }
}

extension Build {

    public struct Attributes: Decodable {
        /// The version number of the uploaded build
        public let version: String
        /// The processing state of the build indicating that it is not yet available for testing.
        public let processingState: ProcessingState

        public init(
            version: String,
            processingState: ProcessingState) {

            self.version = version
            self.processingState = processingState
        }
    }

    public enum ProcessingState: String, Decodable {
        case processing = "PROCESSING"
        case failed = "FAILED"
        case invalid = "INVALID"
        case valid = "VALID"
    }
}
