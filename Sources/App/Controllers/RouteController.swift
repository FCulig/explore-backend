//
//  RouteController.swift
//  
//
//  Created by Filip Culig on 25.10.2021..
//

import Fluent
import Vapor

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
    }
}

// MARK: - Routes -

private extension RouteController {
    
}
