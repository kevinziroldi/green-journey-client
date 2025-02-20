import Foundation
import SwiftData

@Model
class Travel: Codable {
    var travelID: Int?
    var CO2Compensated: Float64 = 0
    var confirmed: Bool
    var userID: Int
 
    init(travelID: Int? = nil, userID: Int, confirmed: Bool? = false) {
        self.travelID = travelID
        self.userID = userID
        self.confirmed = confirmed ?? false
    }
    
    init(travelCopy: Travel) {
        self.travelID = travelCopy.travelID
        self.CO2Compensated = travelCopy.CO2Compensated
        self.confirmed = travelCopy.confirmed
        self.userID = travelCopy.userID
    }
    
    enum CodingKeys: String, CodingKey {
        case travelID = "travel_id"
        case CO2Compensated = "co2_compensated"
        case confirmed = "confirmed"
        case userID = "user_id"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.travelID = try container.decode(Int.self, forKey: .travelID)
        self.CO2Compensated = try container.decode(Float64.self, forKey: .CO2Compensated)
        self.confirmed = try container.decode(Bool.self, forKey: .confirmed)
        self.userID = try container.decode(Int.self, forKey: .userID)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(travelID, forKey: .travelID)
        try container.encode(CO2Compensated, forKey: .CO2Compensated)
        try container.encode(confirmed, forKey: .confirmed)
        try container.encode(userID, forKey: .userID)
    }
}
