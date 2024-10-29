import Foundation
import Combine

class NetworkManager {
    static let shared = NetworkManager()
    private let baseURL = "http://192.168.1.43:8080"
    
    private init() {}
    
    func getBaseURL() -> String {
        return baseURL
    }
}
