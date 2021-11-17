import Vapor
import Fluent
import FluentPostgresDriver
import JWT

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    app.routes.defaultMaxBodySize = "5Mb"

    let corsConfiguration = CORSMiddleware.Configuration(
        allowedOrigin: .all,
        allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE, .PATCH],
        allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith, .userAgent, .accessControlAllowOrigin]
    )
    let cors = CORSMiddleware(configuration: corsConfiguration)
    // cors middleware should come before default error middleware using `at: .beginning`
    app.middleware.use(cors, at: .beginning)
    
    // MARK: - Configure JWT signing
    app.jwt.signers.use(.hs256(key: "SIGNING_SECRET"))
    
    // MARK: - Configure database
    app.databases.use(.postgres(
        hostname: "localhost",
        username: "postgres",
        password: "slatina67",
        database: "explore"
    ), as: .psql)
    
    // MARK: - Configure migrations
    app.migrations.add(CreateUsers())
    app.migrations.add(CreateRoutes())
    
    try app.autoMigrate().wait()
    
    // MARK: - Register routes
    try routes(app)
}
