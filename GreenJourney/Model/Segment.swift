//
//  Segment.swift
//  GreenJourney
//
//  Created by matteo volpari on 13/10/24.
//
import Foundation

class Segment: Decodable, Identifiable {
    var id = UUID()
    var segmentID: Int
    var departure: String
    var destination: String
    var dateTime: Date
    var duration: Duration
    var vehicle: Vehicle
    var description: String
    var price: Float64
    var co2Emitted: Float64
    var numSegment: Int
    var isOutBound: Bool
    var travelID: Int?
    
    init(segmentID: Int, departure: String, destination: String, dateTime: Date, duration: Duration, vehicle: Vehicle, description: String, price: Float64, co2Emitted: Float64, numSegment: Int, isOutBound: Bool, travelID: Int? = nil) {
        self.segmentID = segmentID
        self.departure = departure
        self.destination = destination
        self.dateTime = dateTime
        self.duration = duration
        self.vehicle = vehicle
        self.description = description
        self.price = price
        self.co2Emitted = co2Emitted
        self.numSegment = numSegment
        self.isOutBound = isOutBound
        self.travelID = travelID
    }
}
