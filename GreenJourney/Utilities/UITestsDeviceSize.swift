import Foundation
import SwiftUI

enum DeviceSize: String {
    case compact = "compact"
    case regular = "regular"
}

class UITestsDeviceSize {
    static var deviceSize: DeviceSize {
        /*let bundle = Bundle(for: UITestsDeviceSize.self)
        guard let url = bundle.url(forResource: "Config", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let config = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any]
        else { return .compact }
        if let stringValue = config["UITestsDeviceSize"] as? String {
            return DeviceSize(rawValue: stringValue) ?? .compact
        }
        return .compact*/
        if UIDevice.current.userInterfaceIdiom == .pad{
            return .regular
        }
        else {
            return .compact
        }
    }
}
