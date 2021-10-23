//
//  UserError.swift
//  
//
//  Created by Filip Culig on 23.10.2021..
//

import Vapor

enum UserError {
    case emailTaken
}

extension UserError: AbortError {
    var description: String {
        reason
    }
    
    var status: HTTPResponseStatus {
        switch self {
        case .emailTaken: return .conflict
        }
    }
    
    var reason: String {
        switch self {
        case .emailTaken: return "User with this email already exists"
        }
    }
}
