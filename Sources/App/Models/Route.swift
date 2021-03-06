//
//  Route.swift
//  
//
//  Created by Filip Culig on 29.10.2021..
//

import Fluent
import Vapor

// MARK: - Route model -

final class Route: Model, Content {
    
    // MARK: - Schema definition -

    static let schema = "routes"

    // MARK: - Route properties -
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "coordinates")
    var coordinates: String
    
    @Field(key: "type")
    var type: String
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "description")
    var description: String
    
    @Field(key: "image_name")
    var image_name: String
    
    @Parent(key: "user_id")
    var user: User
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    // MARK: - Initializers -
    
    init() {}
    
    init(
        id: UUID? = nil,
        coordinates: String,
        type: String,
        name: String,
        description: String,
        image_name: String,
        user_id: User.IDValue
    ) {
        self.id = id
        self.coordinates = coordinates
        self.type = type
        self.name = name
        self.description = description
        self.image_name = image_name
        self.$user.id = user_id
    }
}

// MARK: - Route extension -

extension Route {
    static func create(from createRoute: CreateRoute, image_name: String, user_id: User.IDValue) throws -> Route {
        Route(
            coordinates: createRoute.coordinates,
            type: createRoute.type,
            name: createRoute.name,
            description: createRoute.description,
            image_name: image_name,
            user_id: user_id
        )
    }
}

// MARK: - RouteDetails -

struct RouteWithUser: Content {
    let route: Route
    let user: User
}

// MARK: - CreateRoute -

struct CreateRoute: Content {
    let coordinates: String
    let type: String
    let name: String
    let description: String
    let image: File
}

// MARK: - CreateRoute validation -

extension CreateRoute: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("coordinates", as: String.self, is: !.empty)
        validations.add("type", as: String.self, is: !.empty)
        validations.add("name", as: String.self, is: !.empty)
        validations.add("description", as: String.self, is: !.empty)
    }
}

