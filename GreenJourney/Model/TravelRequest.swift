//
//  TravelRequest.swift
//  GreenJourney
//
//  Created by matteo volpari on 13/10/24.
//

class TravelRequest: Decodable {
    var travel: Travel
    var segments: [Segment]
    
}
