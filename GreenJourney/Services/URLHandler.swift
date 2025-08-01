import Foundation

class URLHandler {
    static let shared = URLHandler()
    private var baseURL = ""
    
    private init() {
        if let serverIP = ConfigReader.serverIP {
            if let serverPort = ConfigReader.serverPort {
                baseURL = "https://" + serverIP + ":" + serverPort
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
    
    func getURLSession() -> URLSession {
        return URLSession(configuration: .default, delegate: InsecureSessionDelegate(), delegateQueue: nil)
    }
}
