import Foundation

class TravelDetails: Codable, Identifiable {
    var id = UUID()
    var travel: Travel
    var segments: [Segment]
    
    enum CodingKeys: String, CodingKey {
        case travel = "travel"
        case segments = "segments"
    }
}
