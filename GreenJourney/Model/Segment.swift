import Foundation
import SwiftData

@Model
class Segment: Codable, Identifiable {
    var segmentID: Int
    var departureID: Int
    var destinationID: Int
    var departure: String
    var destination: String
    var date: Date
    var duration: Int
    var vehicle: Vehicle
    var segmentDescription: String
    var price: Float64
    var co2Emitted: Float64
    var distance: Float64
    var numSegment: Int
    var isOutward: Bool
    var travelID: Int
    
    var id: UUID = UUID()
   
    init(segmentID: Int, departureID: Int, destinationID: Int, departure: String, destination: String, date: Date, duration: Int, vehicle: Vehicle, segmentDescription: String, price: Float64, co2Emitted: Float64, distance: Float64, numSegment: Int, isOutward: Bool, travelID: Int) {
        self.segmentID = segmentID
        self.departureID = departureID
        self.destinationID = destinationID
        self.departure = departure
        self.destination = destination
        self.date = date
        self.duration = duration
        self.vehicle = vehicle
        self.segmentDescription = segmentDescription
        self.price = price
        self.co2Emitted = co2Emitted
        self.distance = distance
        self.numSegment = numSegment
        self.isOutward = isOutward
        self.travelID = travelID
        self.id = UUID()
    }
    
    enum CodingKeys: String, CodingKey {
        case segmentID = "segment_id"
        case departureID = "departure_id"
        case destinationID = "destination_id"
        case departure = "departure"
        case destination = "destination"
        case date = "date"
        case duration = "duration"
        case vehicle = "vehicle"
        case segmentDescription = "description"
        case price = "price"
        case co2Emitted = "co2_emitted"
        case distance = "distance"
        case numSegment = "num_segment"
        case isOutward = "is_outward"
        case travelID = "travel_id"
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.segmentID = try container.decode(Int.self, forKey: .segmentID)
        self.departureID = try container.decode(Int.self, forKey: .departureID)
        self.destinationID = try container.decode(Int.self, forKey: .destinationID)
        self.departure = try container.decode(String.self, forKey: .departure)
        self.destination = try container.decode(String.self, forKey: .destination)
        self.date = try container.decode(Date.self, forKey: .date)
        self.duration = try container.decode(Int.self, forKey: .duration)
        self.vehicle = try container.decode(Vehicle.self, forKey: .vehicle)
        self.segmentDescription = try container.decode(String.self, forKey: .segmentDescription)
        self.price = try container.decode(Float64.self, forKey: .price)
        self.co2Emitted = try container.decode(Float64.self, forKey: .co2Emitted)
        self.distance = try container.decode(Float64.self, forKey: .distance)
        self.numSegment = try container.decode(Int.self, forKey: .numSegment)
        self.isOutward = try container.decode(Bool.self, forKey: .isOutward)
        self.travelID = try container.decode(Int.self, forKey: .travelID)
        self.id = UUID()
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(segmentID, forKey: .segmentID)
        try container.encode(departureID, forKey: .departureID)
        try container.encode(destinationID, forKey: .destinationID)
        try container.encode(departure, forKey: .departure)
        try container.encode(destination, forKey: .destination)
        try container.encode(date, forKey: .date)
        try container.encode(duration, forKey: .duration)
        try container.encode(vehicle, forKey: .vehicle)
        try container.encode(segmentDescription, forKey: .segmentDescription)
        try container.encode(price, forKey: .price)
        try container.encode(co2Emitted, forKey: .co2Emitted)
        try container.encode(distance, forKey: .distance)
        try container.encode(numSegment, forKey: .numSegment)
        try container.encode(isOutward, forKey: .isOutward)
        try container.encode(travelID, forKey: .travelID)
    }
}
