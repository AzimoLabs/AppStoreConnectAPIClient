//
//  ResultExtensions.swift
//  
//
//  Created by Mateusz Kuznik on 01/12/2019.
//

import Foundation


extension Result {

    struct Concatenated<Other> {
        let success: Success
        let other: Other
    }

    enum ConcatenatedError<Other>: Error {
        case both(Failure, Other)
        case failure(Failure)
        case other(Other)
    }

    func concatenate<OtherSuccess, OtherFailure, NewFailure>(_ other: Result<OtherSuccess, OtherFailure>, mapError: (ConcatenatedError<OtherFailure>) -> NewFailure) -> Result<Concatenated<OtherSuccess>, NewFailure>  {

        switch (self, other) {
        case let (.success(selfSuccess), .success(otherSuccess)):
            return .success(Concatenated(success: selfSuccess, other: otherSuccess))
        case let (.failure(selfError), .failure(otherError)):
            return .failure(mapError(.both(selfError, otherError)))
        case let (.failure(error), _):
            return .failure(mapError(.failure(error)))
        case let (_, .failure(error)):
            return .failure(mapError(.other(error)))
        }
    }

    func execute(onSuccess: (Success) -> (), onFailure: (Failure) -> ()) {
        switch self {
        case let .success(value):
            onSuccess(value)
        case let .failure(error):
            onFailure(error)
        }
    }
}
