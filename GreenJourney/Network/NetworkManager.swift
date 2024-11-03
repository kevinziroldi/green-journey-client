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
    static var serverPort: String? {
        guard let url = Bundle.main.url(forResource: "Config", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let config = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any]
        else { return nil }
        return config["ServerPort"] as? String
    }
}

class NetworkManager {
    static let shared = NetworkManager()
    private var baseURL = ""
    
    private init() {
        if let serverIP = Config.serverIP {
            if let serverPort = Config.serverPort {
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
