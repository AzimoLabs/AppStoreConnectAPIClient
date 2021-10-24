//
//  ProfileRequest.swift
//  
//
//  Created by Mateusz Kuznik on 22/11/2019.
//

import Foundation


public struct ProfileRequest { }

extension ProfileRequest {

    public enum Field: Hashable {
        case certificates(CertificateField)
        case devices(DeviceField)
        case profiles(ProfileField)
        case bundleIds(BundleIdField)
    }

    public enum CertificateField: String {
        case certificateContent, certificateType, csrContent, displayName, expirationDate, name, platform, serialNumber
    }

    public enum DeviceField: String {
        case addedDate, deviceClass, model, name, platform, status, udid
    }

    public enum ProfileField: String {
        case bundleId, certificates, createdDate, devices, expirationDate, name, platform, profileContent, profileState, profileType, uuid
    }

    public enum BundleIdField: String {
        case bundleIdCapabilities, identifier, name, platform, profiles, seedId
    }
}

extension ProfileRequest.Field: QueryItemData {
    var name: String {
        switch self {
        case .certificates:
            return "fields[certificates]"
        case .devices:
            return "fields[devices]"
        case .profiles:
            return "fields[profiles]"
        case .bundleIds:
            return "fields[bundleIds]"
        }
    }

    var value: String {
        switch self {
        case let .certificates(value):
            return value.rawValue

        case let .devices(value):
            return value.rawValue

        case let .profiles(value):
            return value.rawValue

        case let .bundleIds(value):
            return value.rawValue

        }
    }
}

extension ProfileRequest {

    public enum Filter: Hashable {
        case identifier(String)
        case name(String)
        case profileState(Profile.State)
        case profileType(Profile.Kind)
    }
}

extension ProfileRequest.Filter: QueryItemData {
    var name: String {
        switch self {
        case .identifier:
            return "filter[identifier]"
        case .name:
            return "filter[name]"
        case .profileState:
            return "filter[profileState]"
        case .profileType:
            return "filter[profileType]"
        }
    }

    var value: String {
        switch self {
            case let .identifier(value):
                return value
            case let .name(value):
                return value
            case let .profileState(value):
                return value.rawValue
            case let .profileType(value):
                return value.rawValue
        }
    }
}

extension ProfileRequest {

    public enum IncludeParameter: String {
        case bundleId
        case certificates
        case devices
    }

}

extension ProfileRequest.IncludeParameter: QueryItemData {

    var name: String {
        return "include"
    }
    var value: String {
        return rawValue
    }
}

extension ProfileRequest {

    public enum SortParameter: String {
        case id, name, profileState, profileType
    }

    public enum SortOrder {
        case accessing
        case descending
    }

    public struct Sort: Hashable {
        let by: SortParameter
        let order: SortOrder

        init(
            by: SortParameter,
            order: SortOrder = .accessing) {

            self.by = by
            self.order = order
        }
    }
}

extension ProfileRequest.Sort: QueryItemData {

    var name: String {
        "sort"
    }

    var value: String {
        switch order {
        case .accessing:
            return by.rawValue
        case .descending:
            return "-\(by.rawValue)"
        }
    }
}

extension ProfileRequest {

    public enum Limit: Hashable {
        case profiles(Int)
        case certificates(Int)
        case devices(Int)
    }
}

extension ProfileRequest.Limit: QueryItemData {

    var name: String {
        switch self {
        case .profiles:
            return "limit"
        case .certificates:
            return "limit[certificates]"
        case .devices:
            return "limit[devices]"
        }
    }

    var value: String {
        switch self {
        case let .profiles(value),
             let .certificates(value),
             let .devices(value):

            return "\(value)"
        }
    }
}
