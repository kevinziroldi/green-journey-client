class ServiceFactory {
    static let shared = ServiceFactory()
    
    func getServerService() -> ServerServiceProtocol {
        // check the type of service in the Config
        switch ConfigReader.serverServicesType {
        case .real:
            return ServerService()
        case .mock:
            return MockServerService()
        }
    }
    
    func getFirebaseAuthService() -> FirebaseAuthServiceProtocol {
        // check the type of service in the Config
        switch ConfigReader.serverServicesType {
        case .real:
            return FirebaseAuthService()
        case .mock:
            return MockFirebaseAuthService()
        }
    }
}
