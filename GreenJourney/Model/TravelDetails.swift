//
//  TravelRequest.swift
//  GreenJourney
//
//  Created by matteo volpari on 13/10/24.
//
import Foundation

class TravelDetails: Decodable, Identifiable {
    var id = UUID()
    var travel: Travel
    var segments: [Segment]
    
}
