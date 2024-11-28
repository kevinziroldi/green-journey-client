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
    
    func getDepartureSegment() -> Segment? {
        return self.segments.first
    }
    
    func getDestinationSegment() -> Segment? {
        // last segment with outward = true
        var maxOutwardSegment = -1
        for segment in self.segments {
            if segment.isOutward && segment.numSegment > maxOutwardSegment {
                maxOutwardSegment = segment.numSegment
            }
        }
        // check at least one segment
        if maxOutwardSegment == -1 {
            return nil
        }
        // return last segment destination
        for segment in self.segments {
            if segment.isOutward && segment.numSegment == maxOutwardSegment {
                return segment
            }
        }
        return nil
    }
    
    func sortSegments() {
        self.segments.sort {
            let numSegment1 = $0.numSegment
            let numSegment2 = $1.numSegment
            return numSegment1 < numSegment2
        }
    }
    
}
