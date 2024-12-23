class ServiceFactory {
    static let shared = ServiceFactory()
    
    let serverService: ServerServiceProtocol
    let firebaseAuthService: FirebaseAuthService
    
    private init() {
        // check the type of service in the Config
        switch ConfigReader.serverServicesType {
        case .real:
            self.serverService = ServerService()
            
        case .mock:
            self.serverService = MockServerService()
        }
        self.firebaseAuthService = FirebaseAuthService()
    }
}
