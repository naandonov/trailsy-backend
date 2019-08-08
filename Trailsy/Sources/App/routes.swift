import Vapor

public func routes(_ router: Router) throws {
    
    let authenticationController = AuthenticationController()
    try router.register(collection: authenticationController)
    
    let userController = UserController()
    try router.register(collection: userController)
}
