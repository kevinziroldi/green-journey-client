//
//  OptionDetailsView.swift
//  GreenJourney
//
//  Created by matteo volpari on 18/10/24.
//
import SwiftUI

struct OptionDetailsView: View {
    let segments: [Segment]

    var body: some View {
        if let vehicle = segments.first?.vehicle {
            Text(vehicle.rawValue)
        }
        else {
            Text("no vehicle detected")
        }
        List {
            ForEach (segments) { segment in
                VStack {
                    
                    Text("from: " + segment.departure)
                    Text("to: " + segment.destination)
                    Text("departure: " + segment.date.formatted(date: .numeric, time: .shortened))
                    let arrival = segment.date.addingTimeInterval(TimeInterval(segment.duration / 1000000000))
                    Text("arrival: " + arrival.formatted(date: .numeric, time: .shortened))
                    Text(segment.description)
                    Text("cost: " + String(format: "%.2f", segment.price) + "€")
                    Text("distance: " + String(format: "%.2f", segment.distance) + "km")
                }
            }
        }
        .navigationTitle("Details")
    }
}
