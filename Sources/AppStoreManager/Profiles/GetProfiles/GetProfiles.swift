//
//  AllProfilesRequest.swift
//  
//
//  Created by Mateusz Kuznik on 20/11/2019.
//

import Foundation

extension ProfileRequest {
    public struct GetProfiles {
        public let fields: Set<Field>
        public let filters: Set<Filter>
        public let include: Set<IncludeParameter>
        public let limits: Set<Limit>
        public let sort: Set<Sort>

        public init(
            fields: Set<ProfileRequest.Field>,
            filters: Set<ProfileRequest.Filter>,
            include: Set<ProfileRequest.IncludeParameter>,
            limits: Set<ProfileRequest.Limit>,
            sort: Set<ProfileRequest.Sort>) {
            
            self.fields = fields
            self.filters = filters
            self.include = include
            self.limits = limits
            self.sort = sort
        }
    }
}

extension ProfileRequest.GetProfiles: Request {
    public typealias Response = [Profile]

    public var path: String {
        "profiles"
    }

    public var queryItems: [URLQueryItem] {
        let queryItemFactory = QueryItemDataFactory()
        let allItems: [[QueryItemData]] = [
            fields.toArray(),
            filters.toArray(),
            include.toArray(),
            sort.toArray(),
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
