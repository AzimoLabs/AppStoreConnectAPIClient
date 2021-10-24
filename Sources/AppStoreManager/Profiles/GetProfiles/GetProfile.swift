//
//  GetProfileRequest.swift
//  
//
//  Created by Mateusz Kuznik on 22/11/2019.
//

import Foundation

extension ProfileRequest {
    public struct GetProfile {
        public let profileIdentifier: String
        public let fields: Set<Field>
        public let include: Set<IncludeParameter>
        public let limits: Set<Limit>

        public init(
            profileIdentifier: String,
            fields: Set<ProfileRequest.Field>,
            include: Set<ProfileRequest.IncludeParameter>,
            limits: Set<ProfileRequest.Limit>) {
            
            self.profileIdentifier = profileIdentifier
            self.fields = fields
            self.include = include
            self.limits = limits
        }
    }
}

extension ProfileRequest.GetProfile: Request {
    public typealias Response = Profile

    public var path: String {
        "profiles/\(profileIdentifier)"
    }

    public var queryItems: [URLQueryItem] {
        let queryItemFactory = QueryItemDataFactory()
        let allItems: [[QueryItemData]] = [
            fields.toArray(),
            include.toArray(),
            limits.toArray()
        ]
        let parameters = allItems
            .flatMap { (items) -> [URLQueryItem] in
                items.map(queryItemFactory.createQueryItem)
            }

        return parameters
    }

    public var method: HttpMethod {
        .get
    }

}
