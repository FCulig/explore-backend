import Vapor

func routes(_ app: Application) throws {
    let userService = UserService()
    let routeService = RouteService()
    
    let apiRoutesV1 = app.grouped("api", "v1")
    
    try apiRoutesV1.register(collection: AuthController(userService: userService))
    try apiRoutesV1.register(collection: RouteController(routeService: routeService))
    try apiRoutesV1.register(collection: UserController(userService: userService))
}
