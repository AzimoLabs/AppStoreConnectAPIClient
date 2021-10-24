//
//  HelperDescriptionProvider.swift
//  
//
//  Created by Mateusz Kuznik on 29/11/2019.
//

import Foundation

protocol HelperDescriptionProvider {
    var authorizationIsNeeded: Bool { get }
    static var commandKey: String? { get }
    func helperDescription() -> String
    static func helperDescription() -> String
}

extension HelperDescriptionProvider where Self: CaseIterable {
    static var commandKey: String? { return nil }
    var authorizationIsNeeded: Bool { return true }

    static func helperDescription() -> String {
        let parametersDescription = Self.allCases
            .map { $0.helperDescription() }
            .joined(separator: " ")

        if let commandKey = commandKey {
            return "\(commandKey) \(parametersDescription)"
        } else {
            return "\(parametersDescription)"
        }
    }
}
