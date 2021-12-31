//
//  BodyParameters.swift
//  
//
//  Created by Mateusz Kuznik on 31/12/2021.
//

import Foundation


internal struct BodyParameters<T: Encodable>: Encodable {
    let data: T
}
