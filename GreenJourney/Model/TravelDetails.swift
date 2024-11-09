import Foundation

class TravelDetails: Codable, Identifiable {
    var id = UUID()
    var travel: Travel
    var segments: [Segment]
    
    init(travel: Travel, segments: [Segment]) {
        self.travel = travel
        self.segments = segments
    }
    
    enum CodingKeys: String, CodingKey {
        case travel = "travel"
        case segments = "segments"
    }
}
