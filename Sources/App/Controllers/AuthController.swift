//
//  AuthController.swift
//  
//
//  Created by Filip Culig on 19.10.2021..
//

import Vapor
import Fluent

// MARK: - AuthController -

struct AuthController: RouteCollection {
    
    // MARK: - Private properties -
    
    private let userService: UserService
    
    // MARK: - Initializer -
    
    init (userService: UserService) {
        self.userService = userService
    }
    
    // MARK: - Boot -
    
    func boot(routes: RoutesBuilder) throws {
        let authRoutes = routes.grouped("auth")
        authRoutes.post("register", use: register)
        authRoutes.post("login", use: login)
        
        let tokenProtected = authRoutes.grouped(Token.authenticator(), Token.guardMiddleware())
        tokenProtected.get("me", use: getCurrentUser)
    }
}

// MARK: - Routes -

private extension AuthController {
    func register(req: Request) throws -> EventLoopFuture<User.Public> {
        try UserSignup.validate(content: req)
        let userSignup = try req.content.decode(UserSignup.self)
        let user = try User.create(from: userSignup)
        
        return userService.checkIfUserExists(email: userSignup.email, username: userSignup.username, req: req)
            .flatMap{ exists in
                guard !exists else {
                    return req.eventLoop.future(error: UserError.emailTaken)
                }
                return user.save(on: req.db)
            }.flatMapThrowing{
                try user.asPublic()
            }
    }
    
    func login(req: Request) throws -> EventLoopFuture<TokenResponse> {
        let loginCredentials = try req.content.decode(UserLogin.self)
        
        return User.query(on: req.db)
            .filter(\.$email == loginCredentials.email)
            .first()
            .unwrap(or: Abort(.unauthorized, reason: "Invalid email or password!"))
            .flatMapThrowing { $0 }
            .flatMapThrowing { user in
                if try user.verify(password: loginCredentials.password) {
                    let payload = try Token(userId: user.requireID())
                    return TokenResponse(token: try req.jwt.sign(payload), user: try user.asPublic())
                }
                throw Abort(.unauthorized, reason: "Invalid email or password!")
            }
    }
    
    func getCurrentUser(req: Request) throws -> EventLoopFuture<User.Public> {
        let sessionToken = try req.auth.require(Token.self)
        return User.query(on: req.db)
            .filter(\.$id == sessionToken.userId)
            .first()
            .unwrap(or: Abort(.notFound))
            .flatMapThrowing { try $0.asPublic() }
    }
}
