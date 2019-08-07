//
//  Router+Utilities.swift
//  App
//
//  Created by Nikolay Andonov on 7.08.19.
//

import Foundation
import Vapor
import Authentication

extension Router {
    
    func authorizedRouter() -> Router {
        let tokenAuthenticationMiddleware = User.tokenAuthMiddleware()
        let guardAuthenticationMiddleware = User.guardAuthMiddleware()
        return grouped(tokenAuthenticationMiddleware,
                       guardAuthenticationMiddleware)
    }
    
    func authSessionRouter() -> Router {
        return grouped(User.authSessionsMiddleware())
    }
    
//    func protectedRouter() -> Router {
//        return grouped(RedirectMiddleware<User>(path: WebConstants.UnauthorizedDirectory))
//    }
}
