//
//  RouteController.swift
//  
//
//  Created by Filip Culig on 25.10.2021..
//

import Fluent
import Vapor
import MultipartKit
import Foundation

struct RouteController: RouteCollection {
    
    // MARK: - Private properties -
    
    private let routeService: RouteService
    
    // MARK: - Initializer -
    
    init (routeService: RouteService) {
        self.routeService = routeService
    }
    
    // MARK: - Boot -
    
    func boot(routes: RoutesBuilder) throws {
        let routeRoutes = routes.grouped("route")
        routeRoutes.get(use: getAllRoutes)
        routeRoutes.get(":routeId", use: getRouteById)

        let protectedRoutes = routeRoutes.grouped(Token.authenticator(), Token.guardMiddleware())
        protectedRoutes.post(use: postRoute)
    }
}

// MARK: - Routes -

private extension RouteController {
    func postRoute(req: Request) throws -> EventLoopFuture<Response> {
        let input = try req.content.decode(CreateRoute.self)
        
        let imageName = "\(NSDate().timeIntervalSince1970)-\(input.image.filename)"
        let path = "/Users/filipculig/Desktop/repos/tourist-backend/Explore/Public/\(imageName)"
        
        let sessionToken = try req.auth.require(Token.self)
        let createRoute = try req.content.decode(CreateRoute.self)
        let route = try Route.create(from: createRoute, image_name: imageName, user_id: sessionToken.userId)
        
        return route.save(on: req.db)
            .flatMap {
                req.application.fileio.openFile(path: path,
                                                mode: .write,
                                                flags: .allowFileCreation(posixMode: 0x744),
                                                eventLoop: req.eventLoop)
            }
            .flatMap { handle in
                req.application.fileio.write(fileHandle: handle,
                                             buffer: input.image.data,
                                             eventLoop: req.eventLoop)
                    .flatMapThrowing { _ in
                        try handle.close()
                        return Response(status: .created)
                    }
            }
    }
    
    func getAllRoutes(req: Request) throws -> EventLoopFuture<[Route]> {
        return Route.query(on: req.db).with(\.$user).all()
    }
    
    func getRouteById(req: Request) throws -> EventLoopFuture<Route> {
        let routeId = req.parameters.get("routeId")! as UUID
        return Route.query(on: req.db)
            .with(\.$user)
            .filter(\.$id == routeId)
            .first()
            .unwrap(or: Abort(.notFound))
            .flatMapThrowing { $0 }
    }
}
