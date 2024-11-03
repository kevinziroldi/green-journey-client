import Foundation

class Segment: Codable, Identifiable {
    let segmentID: Int
    let departureID: Int
    let destinationID: Int
    let departure: String
    let destination: String
    let date: Date
    let duration: Int
    let vehicle: Vehicle
    let description: String
    let price: Float64
    let co2Emitted: Float64
    let distance: Float64
    let numSegment: Int
    let isOutward: Bool
    let travelID: Int
    
    var id: UUID = UUID()
   
    enum CodingKeys: String, CodingKey {
        case segmentID = "segment_id"
        case departureID = "departure_id"
        case destinationID = "destination_id"
        case departure = "departure"
        case destination = "destination"
        case date = "date"
        case duration = "duration"
        case vehicle = "vehicle"
        case description = "description"
        case price = "price"
        case co2Emitted = "co2_emitted"
        case distance = "distance"
        case numSegment = "num_segment"
        case isOutward = "is_outward"
        case travelID = "travel_id"
       }
    
    init(segmentID: Int, departureID: Int, destinationID: Int, departure: String, destination: String, date: Date, duration: Int, vehicle: Vehicle, description: String, price: Float64, co2Emitted: Float64, distance: Float64, numSegment: Int, isOutward: Bool, travelID: Int) {
        self.segmentID = segmentID
        self.departureID = departureID
        self.destinationID = destinationID
        self.departure = departure
        self.destination = destination
        self.date = date
        self.duration = duration
        self.vehicle = vehicle
        self.description = description
        self.price = price
        self.co2Emitted = co2Emitted
        self.distance = distance
        self.numSegment = numSegment
        self.isOutward = isOutward
        self.travelID = travelID
        self.id = UUID()
    }
}
