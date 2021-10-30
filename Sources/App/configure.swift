import Vapor
import Fluent
import FluentPostgresDriver

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    // MARK: - Configure database
    app.databases.use(.postgres(
        hostname: "localhost",
        username: "postgres",
        password: "slatina67",
        database: "explore"
    ), as: .psql)
    
    // MARK: - Configure migrations
    app.migrations.add(CreateUsers())
    app.migrations.add(CreateTokens())
    app.migrations.add(CreateRoutes())
    
    try app.autoMigrate().wait()
    
    // MARK: - Register routes
    try routes(app)
}
