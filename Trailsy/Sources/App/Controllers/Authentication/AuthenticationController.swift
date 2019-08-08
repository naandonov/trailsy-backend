//
//  AuthenticationController.swift
//  App
//
//  Created by Nikolay Andonov on 8.08.19.
//

import Foundation
import Vapor

class AuthenticationController: RouteCollection {
    
    func boot(router: Router) throws {
        
        let rootRouter = router.grouped(Constants.Endpoints.v1)
        let authorizedRootRouter = rootRouter.authorizedRouter()
        
        rootRouter.post(User.RegisterRequest.self, at: "register", use: AuthenticationServices.register)
        rootRouter.post(User.LoginRequest.self, at: "login", use: AuthenticationServices.login)
    }
}
