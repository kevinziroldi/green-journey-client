import Foundation

struct TravelOption: Decodable, Hashable {
    let segments: [Segment]
    
    func getCo2Emitted() -> Float64 {
        var co2Emitted: Float64 = 0.0
        for segment in self.segments {
            co2Emitted += segment.co2Emitted
        }
        return co2Emitted
    }
    
    func getTotalPrice () -> Float64 {
        var price: Float64 = 0.0
        for segment in self.segments {
            price += segment.price
        }
        return price
    }
    
    func getGreenPrice () -> Float64 {
        var price: Float64 = 0.0
        for segment in self.segments {
            price += segment.price
        }
        let trees = getNumTrees()
        return price + Double((trees * 2))
    }
    
    func getTotalDuration () -> String {
        var duration = 0
        for segment in self.segments {
            duration += segment.duration/1000000000
        }
        return DurationAsString.convertTotalDurationToString(totalDuration: duration)
    }
    
    func getOptionDeparture () -> String {
        if let firstSegment = self.segments.first {
            return firstSegment.departureCity
        }
        else {
            return ""
        }
    }
    
    func getOptionDestination () -> String {
        if let lastSegment = self.segments.last {
            return lastSegment.destinationCity
        }
        else {
            return ""
        }
    }
    
    func findVehicle() -> String {
        var vehicle: String
        switch self.segments.first?.vehicle {
        case .car:
            vehicle = "car"
        case .train:
            vehicle = "tram"
        case .plane:
            vehicle = "airplane"
        case .bus:
            vehicle = "bus"
        case .walk:
            vehicle = "figure.walk"
        case .bike:
            vehicle = "bicycle"
        default:
            vehicle = ""
        }
        return vehicle
    }
    
    func getNumTrees() -> Int {
        let co2Emitted = getCo2Emitted()
        return Int(ceil(co2Emitted/75))
    }
    
    func getTotalDistance() -> Float64 {
        var distance = 0.0
        for segment in self.segments {
            distance += segment.distance
        }
        return distance
    }
    
    func countChanges() -> Int {
        var changes = 0
        for segment in self.segments {
            if segment.vehicle != .walk {
                changes += 1
            }
        }
        return changes
    }
    
}
