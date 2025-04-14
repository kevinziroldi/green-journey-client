import Foundation

enum TestMode: String {
    case real = "real"
    case test = "test"
}

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
    
    static var testMode: TestMode {
        guard let url = Bundle.main.url(forResource: "Config", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let config = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any]
        else {
            return .real
        }
        if let stringValue = config["TestMode"] as? String {
            print(TestMode(rawValue: stringValue) ?? .real)
            return TestMode(rawValue: stringValue) ?? .real
        }
        return .real
    }
}
