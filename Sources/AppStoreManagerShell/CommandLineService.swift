//
//  CommandLineService.swift
//  
//
//  Created by Mateusz Kuznik on 29/11/2019.
//

import Foundation
import os

struct CommandLineService {

    private let arguments: [String]

    /// Initialize the *CommandLineService*
    ///
    /// The provided *arguments* have to be a full array of launch arguments including the patch to the script file.
    ///
    /// - Parameter arguments: The array with arguments passed on launch.
    init(arguments: [String]) {
        self.arguments = arguments
    }

    /// Returns the name of script's file name
    ///
    /// If provided durring initialization *arguments* parameter is an empty array the process will be terminated
    /// with exit code 1 (**exit(1)**) and the error message will be printed (using **os_log**).
    ///
    /// - Returns: The name of the file.
    func getScriptName() -> String {
        guard let fullPath = arguments.first,
            let name = fullPath.components(separatedBy: "/").last
        else {
            //This should never happend. All shell command has as a first argument the path to the script file
            os_log("Missing script name 🤷🏻‍♂️", log: Logger.logger, type: .error)
            exit(1)
        }
        return name
    }

    /// Action determinate what should be done. For example: *registerDevice*
    ///
    /// All actions are defined by the **ActionCommand** enum
    ///
    /// - Returns: the action to perform or **nil** if not exist.
    func getActionCommand() -> String? {
        return arguments.dropFirst().first
    }

    /// Returns value for a given argument name or **nil** if not exists.
    ///
    /// This is a helper method. Usualy arguments are stored in some **RawRepresentable** enum. You can use this method to pass just an enum case. Undherneath this function calls the *value(forArgument: String) -> String?*
    ///
    /// - Parameter argument: the raw representable argument
    func value<Value: RawRepresentable>(for argument: Value) -> Result<String, Self.Error> where Value.RawValue == String {
        return value(forArgument: argument.rawValue)
    }

    /// Returns value for a given argument name or error if argument or value not exist.
    ///
    /// - Parameter argument: the name of the argument. The name have to be a full name. If name contains for example a prefix *-* or *--* then it have to be included in the provided argument name
    func value(forArgument argument: String) -> Result<String, Self.Error> {
        guard let index = arguments.firstIndex(of: argument) else {
            return .failure("Missing \(argument)")
        }

        let valueIndex = arguments.index(after: index)
        guard arguments.indices.contains(valueIndex) else {
            return .failure("Missing \(argument)'s value")
        }
        return .success(arguments[valueIndex])
    }
}


extension CommandLineService {
    struct Error: Swift.Error {
        /// The message is a full error description. You can just present it to the user.
        let message: String
    }
}

extension CommandLineService.Error: ExpressibleByStringLiteral, ExpressibleByStringInterpolation {

    init(stringLiteral: String) {
        self = Self(message: stringLiteral)
    }
}
