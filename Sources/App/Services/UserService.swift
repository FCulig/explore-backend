//
//  UserService.swift
//  
//
//  Created by Filip Culig on 25.10.2021..
//

import Vapor
import Fluent

final class UserService {
    
    init() { }
}

// MARK: - Public methods

extension UserService {
    func checkIfUserExists(_ email: String, req: Request) -> EventLoopFuture<Bool> {
        User.query(on: req.db)
            .filter(\.$email == email)
            .first()
            .map { $0 != nil }
    }
}
