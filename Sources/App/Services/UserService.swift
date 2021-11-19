//
//  UserService.swift
//  
//
//  Created by Filip Culig on 25.10.2021..
//

import Vapor
import Fluent

// MARK: - UserService -

final class UserService {
    
    // MARK: - Initializer -
    
    init() { }
}

// MARK: - Public methods -

extension UserService {
    func checkIfUserExists(email: String, username: String, req: Request) -> EventLoopFuture<Bool> {
        User.query(on: req.db)
            .filter(\.$email == email)
            .filter(\.$username == username)
            .first()
            .map { $0 != nil }
    }
}
