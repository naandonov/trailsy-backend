import FluentPostgreSQL
import Authentication
import Vapor

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    // Register providers first
    try services.register(FluentPostgreSQLProvider())
    try services.register(AuthenticationProvider())

    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    // Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    // middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    middlewares.use(SessionsMiddleware.self)
    services.register(middlewares)

    let postgresqlConfig: PostgreSQLDatabaseConfig
    if let url = Environment.DATABASE_URL {
        postgresqlConfig = PostgreSQLDatabaseConfig(url: url, transport: .unverifiedTLS)!
    }
    else {
        postgresqlConfig = PostgreSQLDatabaseConfig(
            hostname: "localhost",
            username: "nikolay.andonov",
            database: "trailsy.local",
            password: nil
        )
    }
    
    // Configure a PostgreSQL database
    let postgresqlDatabase = PostgreSQLDatabase(config: postgresqlConfig)
    
    var databases = DatabasesConfig()
    databases.add(database: postgresqlDatabase, as: .psql)
    services.register(databases)

    // Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: User.self, database: .psql)
    migrations.add(migration: AdminUser.self, database: .psql)
    migrations.add(model: Token.self, database: .psql)
    migrations.add(model: Device.self, database: .psql)
    services.register(migrations)
    
    config.prefer(MemoryKeyedCache.self, for: KeyedCache.self)
}
