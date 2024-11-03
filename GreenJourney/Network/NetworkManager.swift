import Foundation
import Combine

struct Config {
    static var serverIP: String? {
        guard let url = Bundle.main.url(forResource: "Config", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let config = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any]
        else { return nil }
        return config["ServerIP"] as? String
    }
}

class NetworkManager {
    static let shared = NetworkManager()
    private var baseURL = ""
    
    private init() {
        if let serverIP = Config.serverIP {
            baseURL = "http://" + serverIP + ":80"
        }else {
            print("Error loading server IP from Config")
        }
    }
    
    func getBaseURL() -> String {
        return baseURL
    }
}
