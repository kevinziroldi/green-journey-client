//
//  Segment.swift
//  GreenJourney
//
//  Created by matteo volpari on 13/10/24.
//
import Foundation

class Segment: Decodable, Identifiable {
    let segmentID: Int
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
    let isOutbound: Bool
    let travelID: Int
    
    var id: UUID = UUID()
   
    enum CodingKeys: String, CodingKey {
        case segmentID = "segment_id"
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
        case isOutbound = "is_outbound"
        case travelID = "travel_id"
       }
    
    init(segmentID: Int, departure: String, destination: String, date: Date, duration: Int, vehicle: Vehicle, description: String, price: Float64, co2Emitted: Float64, distance: Float64, numSegment: Int, isOutbound: Bool, travelID: Int) {
        self.segmentID = segmentID
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
        self.isOutbound = isOutbound
        self.travelID = travelID
        self.id = UUID()
    }
}
