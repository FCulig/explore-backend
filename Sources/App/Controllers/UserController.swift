//
//  UserController.swift
//  
//
//  Created by Filip Culig on 19.11.2021..
//

import Vapor
import Fluent

// MARK: - UserController -

struct UserController: RouteCollection {
    
    // MARK: - Private properties -
    
    private let userService: UserService
    
    // MARK: - Initializer -
    
    init (userService: UserService) {
        self.userService = userService
    }
    
    // MARK: - Boot -
    
    func boot(routes: RoutesBuilder) throws {
        let userRoutes = routes.grouped("user")
        userRoutes.get(":username", use: getUserByUsername)
        
        let tokenProtected = userRoutes.grouped(Token.authenticator(), Token.guardMiddleware())
        tokenProtected.put("image", use: updateUserImage)
    }
}

// MARK: - Routes -

private extension UserController {
    func updateUserImage(req: Request) throws -> EventLoopFuture<EventLoopFuture<Response>> {
        let input = try req.content.decode(UserImageUpdate.self)
        
        let imageName = "\(NSDate().timeIntervalSince1970)-\(input.profile_image.filename)"
        let basePath = "/Users/filipculig/Desktop/repos/tourist-backend/Explore/Public/"
        let path = "\(basePath)\(imageName)"
        
        let sessionToken = try req.auth.require(Token.self)
        return User.query(on: req.db)
            .filter(\.$id == sessionToken.userId)
            .first()
            .unwrap(or: Abort(.notFound))
            .flatMapThrowing { user -> User in
                let filepath = basePath + user.profile_image
                try FileManager.default.removeItem(atPath: filepath)
                return user
            }
            .flatMapThrowing { user -> User in
                user.profile_image = imageName
                return user
            }
            .flatMapThrowing {
                $0.update(on: req.db)
            }
            .flatMap {
                req.application.fileio.openFile(path: path,
                                                mode: .write,
                                                flags: .allowFileCreation(posixMode: 0x744),
                                                eventLoop: req.eventLoop)
            }
            .flatMapThrowing { handle in
                req.application.fileio.write(fileHandle: handle,
                                             buffer: input.profile_image.data,
                                             eventLoop: req.eventLoop)
                    .flatMapThrowing { _ -> Response in
                        try handle.close()
                        return Response(status: .ok)
                    }
            }
    }
    
    func getUserByUsername(req: Request) throws -> EventLoopFuture<User.PublicWithRoutes> {
        let username = req.parameters.get("username")!
        return User.query(on: req.db)
            .with(\.$routes)
            .filter(\.$username == username)
            .first()
            .unwrap(or: Abort(.notFound))
            .flatMapThrowing { $0 }
            .flatMapThrowing { try $0.asPublicWithRoutes() }
    }
}
