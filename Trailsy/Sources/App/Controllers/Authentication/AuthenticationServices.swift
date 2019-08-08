//
//  AuthenticationServices.swift
//  App
//
//  Created by Nikolay Andonov on 8.08.19.
//

import Foundation
import Vapor
import FluentPostgreSQL
import Crypto
import Random

class AuthenticationServices {
    
    class func register(request: Request, registerRequest: User.RegisterRequest) throws -> Future<HTTPStatus> {
        
        return User.query(on: request).group(.or) { builder in
            builder.filter(\User.email == registerRequest.email)
//            builder.filter(\User.username == registerRequest.username)
            }.first().flatMap({ duplicateUser -> Future<HTTPStatus> in
                if let duplicateUser = duplicateUser {
                    throw Abort(.badRequest, reason: "Registration for '\(duplicateUser.email)' already exists")
                }
                
                let user = User(name: registerRequest.name,
                                email: registerRequest.email,
                                password: try BCryptDigest().hash(registerRequest.password))
                
                return user.save(on: request).transform(to: .created)
            })
    }
    
    class func login(request: Request, loginRequest: User.LoginRequest) throws -> Future<Token.PublicElement> {
        let invalidCredentials = Abort(.notFound, reason: "Invalid credentials")
        
        return User.query(on: request)
            .filter(\.email == loginRequest.email)
            .first()
            .flatMap { fetchedUser in
                guard let existingUser = fetchedUser else {
                    throw invalidCredentials
                }
                let hasher = try request.make(BCryptDigest.self)
                if try hasher.verify(loginRequest.password, created: existingUser.password) {
                    return try logoutHelper(request, user: existingUser)
                        .flatMap { _ in
                            let tokenString = try URandom().generateData(count: 32).base64EncodedString()
                            let token = try Token(token: tokenString, userId: existingUser.requireID())
                            return token.save(on: request).mapToPublic()
                    }
                } else {
                    throw invalidCredentials
                }
        }
    }
}

//MARK: - Utilities

extension AuthenticationServices {
    private class func logoutHelper(_ request: Request, user: User) throws -> Future<HTTPResponse> {
        return try Token
            .query(on: request)
            .filter(\Token.userId, .equal, user.requireID())
            .delete()
            .flatMap{ _ in
                try user.userDevice.query(on: request)
                    .delete()
                    .transform(to: HTTPResponse(status: .ok))
        }
    }
}
