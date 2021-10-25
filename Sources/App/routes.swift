import Vapor

func routes(_ app: Application) throws {
    let userService = UserService()
    
    let apiRoutesV1 = app.grouped("api", "v1")
    
    try apiRoutesV1.register(collection: AuthController(userService: userService))
}
