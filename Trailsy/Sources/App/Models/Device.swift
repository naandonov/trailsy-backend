//
//  Device.swift
//  App
//
//  Created by Nikolay Andonov on 7.08.19.
//

import Foundation
import Vapor
import FluentPostgreSQL

final class Device: Content {
    
    var id: Int?
    var deviceToken: String
    var userId: User.ID?
    
    init(deviceToken: String) {
        self.deviceToken = deviceToken
    }
}

//MARK: - Parameter

extension Device: Parameter {}

//MARK: - PostgreSQLModel

extension Device: PostgreSQLModel {}

//MARK: - Migration

extension Device: Migration {
    
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection, closure: { builder in
            try addProperties(to: builder)
            builder.reference(from: \.userId, to: \User.id)
        })
    }
}
