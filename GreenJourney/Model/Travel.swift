import Foundation
import SwiftData

@Model
class Travel: Codable {
    var travelID: Int?
    var CO2Compensated: Float64 = 0
    var userID: Int
 
    init (travelID: Int? = nil, userID: Int) {
        self.userID = userID
        self.travelID = travelID
    }
    
    enum CodingKeys: String, CodingKey {
        case travelID = "travel_id"
        case CO2Compensated = "co2_compensated"
        case userID = "user_id"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.travelID = try container.decode(Int.self, forKey: .travelID)
        self.CO2Compensated = try container.decode(Float64.self, forKey: .CO2Compensated)
        self.userID = try container.decode(Int.self, forKey: .userID)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(travelID, forKey: .travelID)
        try container.encode(CO2Compensated, forKey: .CO2Compensated)
        try container.encode(userID, forKey: .userID)
    }
}
