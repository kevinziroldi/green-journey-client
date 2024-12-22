class URLHandler {
    static let shared = URLHandler()
    private var baseURL = ""
    
    private init() {
        if let serverIP = ConfigReader.serverIP {
            if let serverPort = ConfigReader.serverPort {
                baseURL = "http://" + serverIP + ":" + serverPort
            }else {
                print("Error loading server port from Config")
            }
        }else {
            print("Error loading server IP from Config")
        }
    }
    
    func getBaseURL() -> String {
        return baseURL
    }
}
