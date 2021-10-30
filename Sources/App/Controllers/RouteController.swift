//
//  RouteController.swift
//  
//
//  Created by Filip Culig on 25.10.2021..
//

import Fluent
import Vapor
import MultipartKit

struct RouteController: RouteCollection {
    
    // MARK: - Private properties -
    
    private let routeService: RouteService
    
    // MARK: - Initializer -
    
    init (routeService: RouteService) {
        self.routeService = routeService
    }
    
    // MARK: - Boot -
    
    func boot(routes: RoutesBuilder) throws {
        let routeRoutes = routes
            .grouped(Token.authenticator())
            .grouped("route")
        
        routeRoutes.post(use: postRoute)
        routeRoutes.get(use: getAllRoutes)
    }
}

// MARK: - Routes -

private extension RouteController {
    func postRoute(req: Request) throws -> EventLoopFuture<Route> {
        let user = try req.auth.require(User.self).asPublic()
        let createRoute = try req.content.decode(CreateRoute.self)
        let route = try Route.create(from: createRoute, user_id: user.id)

        return route.save(on: req.db).map { route }
    }
    
    func getAllRoutes(req: Request) throws -> EventLoopFuture<[Route]> {
        return Route.query(on: req.db).with(\.$user).all()
    }
}
