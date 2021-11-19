//
//  CreateUsers.swift
//  
//
//  Created by Filip Culig on 23.10.2021..
//

import Fluent
import FluentPostgresDriver

struct CreateUsers: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(User.schema)
            .id()
            .field("email", .string, .required)
            .unique(on: "email")
            .field("username", .string, .required)
            .unique(on: "username")
            .field("password", .string, .required)
            .field("profile_image", .string, .sql(.default("profile_image.jpg")))
            .field("created_at", .datetime, .required)
            .field("updated_at", .datetime, .required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(User.schema).delete()
    }
}
