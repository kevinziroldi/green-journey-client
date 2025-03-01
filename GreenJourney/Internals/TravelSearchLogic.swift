import Foundation

struct TravelSearchLogic {
    
    func computeCo2Emitted(_ travelOption: [Segment]) -> Float64 {
        var co2Emitted: Float64 = 0.0
        for segment in travelOption {
            co2Emitted += segment.co2Emitted
        }
        return co2Emitted
    }
    
    func computeTotalPrice (_ travelOption: [Segment]) -> Float64 {
        var price: Float64 = 0.0
        for segment in travelOption {
            price += segment.price
        }
        return price
    }
    
    func computeGreenPrice (_ travelOption: [Segment]) -> Float64 {
        var price: Float64 = 0.0
        for segment in travelOption {
            price += segment.price
        }
        let trees = getNumTrees(travelOption)
        return price + Double((trees * 2))
    }
    
    func computeTotalDuration (_ travelOption: [Segment]) -> String {
        var duration = 0
        for segment in travelOption {
            duration += segment.duration/1000000000
        }
        return UtilitiesFunctions.convertTotalDurationToString(totalDuration: duration)
    }
    
    func getOptionDeparture (_ travelOption: [Segment]) -> String {
        if let firstSegment = travelOption.first {
            return firstSegment.departureCity
        }
        else {
            return ""
        }
    }
    
    func getOptionDestination (_ travelOption: [Segment]) -> String {
        if let lastSegment = travelOption.last {
            return lastSegment.destinationCity
        }
        else {
            return ""
        }
    }
    
    func findVehicle(_ option: [Segment]) -> String {
        var vehicle: String
        switch option.first?.vehicle {
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
    
    func getNumTrees(_ travelOption: [Segment]) -> Int {
        let co2Emitted = computeCo2Emitted(travelOption)
        return Int(ceil(co2Emitted/75))
    }
    
    func computeTotalDistance(_ travelOption: [Segment]) -> Float64 {
        var distance = 0.0
        for segment in travelOption {
            distance += segment.distance
        }
        return distance
    }
    
    func countChanges(_ option: [Segment]) -> Int {
        var changes = 0
        for segment in option {
            if segment.vehicle != .walk {
                changes += 1
            }
        }
        return changes
    }
}
