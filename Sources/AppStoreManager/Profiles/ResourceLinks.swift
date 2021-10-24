//
//  ResourceLinks.swift
//  
//
//  Created by Mateusz Kuznik on 20/11/2019.
//

import Foundation

public struct ResourceLinks: Decodable {

    public let link: URL

    public init(link: URL) {
        self.link = link
    }

    private enum CodingKeys: String, CodingKey {
        case link = "self"
    }
}
