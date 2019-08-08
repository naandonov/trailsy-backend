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
    
    var name: String
    var email: String
    var password: String
    
    init(name: String, email: String, password: String) {
        self.name = name
        self.password = password
        self.email = email
    }
}

//MARK: - PublicMappable

extension User: PublicMappable {
    
    struct Public: Content {
        let name: String
        let email: String
        
        init(name: String, email: String) {
            self.name = name
            self.email = email
        }
    }
    
    typealias PublicElement = User.Public
    
    func mapToPublic() -> PublicElement {
        return User.Public(name: name,
                           email: email)
    }
}

//MARK: - Supplementary Models

extension User {
    
    struct RegisterRequest: Content {
        let name: String
        let email: String
        let password: String
    }
    
    struct LoginRequest: Content {
        let email: String
        let password: String
    }
}

//MARK: - Relationships

extension User {
    
    var userDevice: Children<User, Device> {
        return children(\.userId)
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
            builder.unique(on: \.email)
        })
    }
    
}

//MARK: - PasswordAuthenticatable

extension User: PasswordAuthenticatable {
    static var usernameKey: WritableKeyPath<User, String> {
        return \User.email
    }
    static var passwordKey: WritableKeyPath<User, String> {
        return \User.password
    }
}

//MARK: - AdminUser

struct AdminUser: Migration {
    typealias Database = PostgreSQLDatabase
    
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        let password = try? BCrypt.hash("@dm1n")
        guard let hashedPassword = password else {
            fatalError("Failed to create admin user")
        }
        let user = User(name: "Admin",
                        email: "admin@trailsy.io",
                        password: hashedPassword)
        return user.save(on: connection).transform(to: Void())
    }
    
    static func revert(on connection: PostgreSQLConnection) -> Future<Void> {
        return .done(on: connection)
    }
}
