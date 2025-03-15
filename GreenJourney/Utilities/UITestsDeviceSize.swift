import Foundation

enum DeviceSize: String {
    case small = "small"
    case regular = "regular"
}

class UITestsDeviceSize {
    static var deviceSize: DeviceSize {
        let bundle = Bundle(for: UITestsDeviceSize.self)
        guard let url = bundle.url(forResource: "Config", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let config = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any]
        else { return .small }
        if let stringValue = config["UITestsDeviceSize"] as? String {
            return DeviceSize(rawValue: stringValue) ?? .small
        }
        return .small
    }
}
