//
//  Token.swift
//  
//
//  Created by Filip Culig on 23.10.2021..
//

import Vapor
import JWT

// MARK: - Token -

struct Token: Content, Authenticatable, JWTPayload {
    // Constants
    let expirationTime = 60 * 60 * 24 * 30
    
    // Token Data
    var expiration: ExpirationClaim
    var userId: UUID
    
    init(userId: UUID) {
        self.userId = userId
        self.expiration = ExpirationClaim(value: Date().addingTimeInterval(TimeInterval(expirationTime)))
    }
    
    init(user: User) throws {
        self.userId = try user.requireID()
        self.expiration = ExpirationClaim(value: Date().addingTimeInterval(TimeInterval(expirationTime)))
    }
    
    func verify(using signer: JWTSigner) throws {
        try expiration.verifyNotExpired()
    }
}

// MARK: - TokenResponse -

struct TokenResponse: Content {
    var token: String
}
