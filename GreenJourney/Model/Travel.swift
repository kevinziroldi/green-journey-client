import Foundation

class Travel: Codable {
    var travelID: Int
    var CO2Compensated: Float64
    var userID: Int
 
    
    enum CodingKeys: String, CodingKey {
        case travelID = "travel_id"
        case CO2Compensated = "co2_compensated"
        case userID = "user_id"
    }
}
