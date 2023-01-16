//
//  Utilities.swift
//  Paws Go 5
//
//  Created by Pui Ling Hon on 2022-12-21.
//

import Foundation

struct AppError {
    let message : String
    
    init(message: String) {
        self.message = message
    }
}

extension AppError: LocalizedError {
    var errorDescription: String? { return message }
}


