//
//  CreateTokens.swift
//  
//
//  Created by Filip Culig on 23.10.2021..
//

import Fluent
import FluentPostgresDriver

struct CreateTokens: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Token.schema)
            .id()
            .field("user_id", .uuid, .references("users", "id"))
            .field("value", .string, .required)
            .unique(on: "value")
            .field("source", .int, .required)
            .field("created_at", .datetime, .required)
            .field("expires_at", .datetime)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Token.schema).delete()
    }
}
