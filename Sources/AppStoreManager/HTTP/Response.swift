//
//  Response.swift
//  
//
//  Created by Mateusz Kuznik on 22/11/2019.
//

import Foundation

public struct Response<Object: Decodable>: Decodable {
    public let data: Object
}
