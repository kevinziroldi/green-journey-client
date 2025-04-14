import Foundation
import SwiftUI

enum DeviceSize: String {
    case compact = "compact"
    case regular = "regular"
}

class UITestsDeviceSize {
    static var deviceSize: DeviceSize {
        if UIDevice.current.userInterfaceIdiom == .pad{
            return .regular
        } else {
            return .compact
        }
    }
}
