import Foundation

struct ConfigReader {
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
    
    static var dbInstance: String? {
        guard let url = Bundle.main.url(forResource: "Config", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let config = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any]
        else { return nil }
        return config["DBInstance"] as? String
    }
    
    static var serverServicesType: ServiceType {
        guard let url = Bundle.main.url(forResource: "Config", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let config = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any]
        else {
            return .real
        }
        if let stringValue = config["ServerServiceType"] as? String {
            return ServiceType(rawValue: stringValue) ?? .real
        }
        return .real
    }
    
    static var firebaseAuthServiceType: ServiceType {
        guard let url = Bundle.main.url(forResource: "Config", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let config = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any]
        else {
            return .real
        }
        if let stringValue = config["FirebaseAuthServiceType"] as? String {
            return ServiceType(rawValue: stringValue) ?? .real
        }
        return .real
    }
}
