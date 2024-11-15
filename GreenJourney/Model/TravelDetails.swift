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
    
    func getFirstSegment() -> Segment? {
        if let firstListSegment = self.segments.first {
            var firstSegment = firstListSegment
            for segment in self.segments {
                if segment.numSegment < firstSegment.numSegment {
                    firstSegment = segment
                }
            }
            return firstSegment
        }
        return nil
    }
    
    func getLastSegment() -> Segment? {
        if let firstListSegment = self.segments.first {
            var lastSegment = firstListSegment
            for segment in self.segments {
                if segment.numSegment > lastSegment.numSegment {
                    lastSegment = segment
                }
            }
            return lastSegment
        }
        return nil
    }
}
