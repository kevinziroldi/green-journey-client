import Foundation
import Combine

class NetworkManager {
    static let shared = NetworkManager()
    private let baseURL = "http://192.168.5.11:8080"
    
    private init() {}
    
    func getBaseURL() -> String {
        return baseURL
    }
}
