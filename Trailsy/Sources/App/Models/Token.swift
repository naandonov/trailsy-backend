//
//  Token.swift
//  App
//
//  Created by Nikolay Andonov on 7.08.19.
//

import Foundation
import Vapor
import FluentPostgreSQL
import Authentication

final class Token: Content {
    
    var id: Token.ID?
    var token: String
    var userId: User.ID
    
    init(token: String, userId: User.ID) {
        self.token = token
        self.userId = userId
    }
}

//MARK: - PublicMappabble

extension Token: PublicMappable {
    
    struct Public: Content {
        var accessToken: String
    }
    
    typealias PublicElement = ResultWrapper<Token.Public>

    func mapToPublic() -> PublicElement {
        return Token.Public(accessToken: token).parse()
    }
}

//MARK: - Utilities

extension Token {
    
    static func generate(for user: User) throws -> Token {
        let random = try CryptoRandom().generateData(count: 16)
        return try Token(token: random.base64EncodedString(),
                         userId: user.requireID())
    }
}

//MARK: - Authentication.Token

extension Token: Authentication.Token {
    typealias UserType = User
    static var userIDKey: UserIDKey = \Token.userId
}

extension Token: BearerAuthenticatable {
    static var tokenKey: TokenKey = \Token.token
}

//MARK: - Parameter

extension Token: Parameter {}

//MARK: - PostgreSQLModel

extension Token: PostgreSQLUUIDModel {}

//MARK: - Migration

extension Token: Migration {
    
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection, closure: { builder in
            try addProperties(to: builder)
            builder.reference(from: \.userId, to: \User.id)
        })
    }
    
}
