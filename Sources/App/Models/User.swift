//
//  User.swift
//  
//
//  Created by Filip Culig on 23.10.2021..
//

import Fluent
import Vapor

// MARK: - User model -

final class User: Model {
    
    // MARK: - Public properties -
    
    struct Public: Content {
        let id: UUID
        let email: String
        let createdAt: Date?
        let updatedAt: Date?
    }
    
    // MARK: - Schema definition -
    
    static let schema = "users"
    
    // MARK: - User properties -
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "email")
    var email: String
    
    @Field(key: "password")
    var password: String
    
    @Children(for: \.$user)
    var routes: [Route]
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    // MARK: - Initializers -
    
    init() {}
    
    init(id: UUID? = nil, email: String, password: String) {
        self.id = id
        self.email = email
        self.password = password
    }
}

// MARK: - User extension -

extension User {
    static func create(from userSignup: UserSignup) throws -> User {
        User(
            email: userSignup.email,
            password: try Bcrypt.hash(userSignup.password)
        )
    }
    
    func asPublic() throws -> Public {
        Public(
            id: try requireID(),
            email: email,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

// MARK: - Authenticable -

extension User: ModelAuthenticatable {
    static let usernameKey = \User.$email
    static let passwordHashKey = \User.$password
    
    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.password)
    }
}

// MARK: - UserSignup -

struct UserSignup: Content {
    let email: String
    let password: String
}

// MARK: - UserSignup validation -

extension UserSignup: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("email", as: String.self, is: .email)
        validations.add("password", as: String.self, is: .count(6...))
    }
}
