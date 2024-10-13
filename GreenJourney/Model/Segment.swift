//
//  Segment.swift
//  GreenJourney
//
//  Created by matteo volpari on 13/10/24.
//
import Foundation

class Segment: Decodable {
    var segmentID: Int
    var departure: String
    var destination: String
    var dateTime: Date
    var duration: Duration
    var vehicle: String
    var description: String
    var price: Float64
    var co2Emitted: Float64
    var numSegment: Int
    var travelID: Int
}
