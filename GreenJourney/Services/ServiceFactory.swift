class ServiceFactory {
    static let shared = ServiceFactory()
    
    func getServerService() -> ServerServiceProtocol {
        // check the type of service in the Config
        switch ConfigReader.testMode {
        case .real:
            return ServerService()
        case .test:
            return MockServerService()
        }
    }
    
    func getFirebaseAuthService() -> FirebaseAuthServiceProtocol {
        // check the type of service in the Config
        switch ConfigReader.testMode {
        case .real:
            return FirebaseAuthService()
        case .test:
            return MockFirebaseAuthService()
        }
    }
}
