//
//  AuthController.swift
//  
//
//  Created by Filip Culig on 19.10.2021..
//

import Vapor
import Fluent

struct AuthController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        let authRoutes = routes.grouped("auth")
        authRoutes.post("register", use: register)
        
        let passwordProtected = authRoutes.grouped(User.authenticator())
        passwordProtected.post("login", use: login)

        let tokenProtected = authRoutes.grouped(Token.authenticator())
        tokenProtected.get("me", use: getCurrentUser)
    }
}

// MARK: - Routes

private extension AuthController {
    func register(req: Request) throws -> EventLoopFuture<NewSession> {
        try UserSignup.validate(content: req)
        let userSignup = try req.content.decode(UserSignup.self)
        let user = try User.create(from: userSignup)
        var token: Token!
        
        return checkIfUserExists(userSignup.email, req: req).flatMap { exists in
            guard !exists else {
                return req.eventLoop.future(error: UserError.emailTaken)
            }
            
            return user.save(on: req.db)
        }.flatMap {
            guard let newToken = try? user.createToken(source: .signup) else {
                return req.eventLoop.future(error: Abort(.internalServerError))
            }
            token = newToken
            return token.save(on: req.db)
        }.flatMapThrowing {
            NewSession(token: token.value, user: try user.asPublic())
        }
    }
    
    func login(req: Request) throws -> EventLoopFuture<NewSession> {
        let user = try req.auth.require(User.self)
        let token = try user.createToken(source: .login)
        
        return token.save(on: req.db).flatMapThrowing {
            NewSession(token: token.value, user: try user.asPublic())
        }
    }
    
    func getCurrentUser(req: Request) throws -> User.Public {
        try req.auth.require(User.self).asPublic()
    }
}

// TODO: Clean up

private extension AuthController {
    private func checkIfUserExists(_ email: String, req: Request) -> EventLoopFuture<Bool> {
        User.query(on: req.db)
            .filter(\.$email == email)
            .first()
            .map { $0 != nil }
    }
}
