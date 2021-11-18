//
//  CreateRoutes.swift
//  
//
//  Created by Filip Culig on 30.10.2021..
//


import Fluent
import FluentPostgresDriver

struct CreateRoutes: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Route.schema)
            .id()
            .field("coordinates", .string, .required)
            .field("type", .string, .required)
            .field("name", .string, .required)
            .field("description", .string, .required)
            .field("image_name", .string, .required)
            .field("user_id", .uuid, .required, .references("users", .id))
            .field("created_at", .datetime, .required)
            .field("updated_at", .datetime, .required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Route.schema).delete()
    }
}
