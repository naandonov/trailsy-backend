//
//  User.swift
//  App
//
//  Created by Nikolay Andonov on 6.08.19.
//

import Foundation
import Vapor
import FluentPostgreSQL
import Authentication

final class User: Content {
    
    var id: User.ID?
    
    let name: String
    let username: String
    let password: String
    
    init(name: String, username: String, password: String) {
        self.name = name
        self.username = username
        self.password = password
    }
}

//MARK: - PublicMappable

extension User: PublicMappable {
    
    final class Public: Content {
        let name: String
        
        init(name: String) {
            self.name = name
        }
    }
    
    typealias PublicElement = User.Public
    
    func mapToPublic() -> PublicElement {
        return User.Public(name: name)
    }
}

//MARK: - TokenAuthenticatable

extension User: TokenAuthenticatable {
    typealias TokenType = Token
}

//MARK: - SessionAuthenticatable

extension User: SessionAuthenticatable {}

//MARK: - Parameter

extension User: Parameter {}

//MARK: - PostgreSQLModel

extension User: PostgreSQLUUIDModel {}

//MARK: - Migration

extension User: Migration {
    
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection, closure: { builder in
            try addProperties(to: builder)
            builder.unique(on: \.username)
        })
    }
    
}

struct AdminUser: Migration {
    typealias Database = PostgreSQLDatabase
    
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        let password = try? BCrypt.hash("@dm1n")
        guard let hashedPassword = password else {
            fatalError("Failed to create admin user")
        }
        let user = User(name: "Admin",
                        username: "admin",
                        password: hashedPassword)
        return user.save(on: connection).transform(to: Void())
    }
    
    static func revert(on connection: PostgreSQLConnection) -> Future<Void> {
        return .done(on: connection)
    }
}
