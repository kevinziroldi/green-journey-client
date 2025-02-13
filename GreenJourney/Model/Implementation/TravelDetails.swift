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
    
    func computeCo2Emitted() -> Float64 {
        var co2Emitted = 0.0
        for segment in self.segments {
            co2Emitted += segment.co2Emitted
        }
        return co2Emitted
    }
    
    func computeTotalPrice() -> Float64 {
        var totalPrice = 0.0
        for segment in self.segments {
            totalPrice += segment.price
        }
        return totalPrice
    }
    
    func computeTotalDistance() -> Float64 {
        var totalDistance = 0.0
        for segment in self.segments {
            totalDistance += segment.distance
        }
        return totalDistance
    }
    
    func computeTotalDuration() -> String {
        var totalDuration = 0
        var hours: Int = 0
        var minutes: Int = 0
        for segment in self.segments {
            totalDuration += segment.duration
        }
        hours = totalDuration / (3600 * 1000000000)       // 1 hour = 3600 secsecondsondi
        let remainingSeconds = (totalDuration / 1000000000) % (3600)
        minutes = remainingSeconds / 60
        while (minutes >= 60) {
            hours += 1
            minutes -= 60
        }
        return "\(hours) h, \(minutes) m"
    }
    
    func isOneway() -> Bool {
        for segment in segments {
            if !segment.isOutward {
                return false
            }
        }
        return true
    }
    
    func getOutwardSegments() -> [Segment] {
        var outwardSegments: [Segment] = []
        for segment in segments {
            if segment.isOutward {
                outwardSegments.append(segment)
            }
        }
        return outwardSegments
    }
    
    func getReturnSegments() -> [Segment] {
        var returnSegments: [Segment] = []
        for segment in segments {
            if !segment.isOutward {
                returnSegments.append(segment)
            }
        }
        return returnSegments
    }
    
    func findVehicle(isOneway: Bool) -> String {
        var vehicle: String = ""
        var segments: [Segment] = []
        if isOneway {
            segments = self.segments
        }
        else {
            segments = getReturnSegments()
        }
        for segment in segments {
            if vehicle != "" {
                return vehicle
            }
            switch segment.vehicle {
            case .car:
                vehicle = "car"
            case .train:
                vehicle = "tram"
            case .plane:
                vehicle = "airplane"
            case .bus:
                vehicle = "bus"
            case .walk:
                vehicle = ""
            case .bike:
                vehicle = "bicycle"
            }
        }
        return vehicle
    }
    
}
