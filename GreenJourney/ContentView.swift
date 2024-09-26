//
//  ContentView.swift
//  GreenJourney
//
//  Created by Kevin Ziroldi on 25/09/24.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var city = ""
    
    var population = 500000.0
    var capital = 1
    var average_temperature = 30.1
    var continent = "Africa"
    var living_cost = 9.079999999999998
    var travel_connectivity = 1.889
    var safety = 6.222000000000001
    var healthcare = 6.301666666666667
    var education = 1.534
    var economy = 4.5945
    var internet_access = 2.9760000000000004
    var outdoors = 7.477
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("City: " + city)
            }
            .navigationTitle("GreenJourney")
            .toolbar {
                Button("Calculate", action: computeCity)
            }
        }
    }
    
    func computeCity() {
        do {
            let config = MLModelConfiguration()
            let model = try GreenJourneyClassifier_v2(configuration: config)
            let prediction = try model.prediction(population: population, capital: Int64(capital), average_temperature:average_temperature,continent:continent,living_cost:living_cost,travel_connectivity:travel_connectivity,safety:safety,healthcare:healthcare,education:education,economy:economy,internet_access:internet_access,outdoors:outdoors)
            city = prediction.city
        }catch{
            city = "error"
        }
    }
}

#Preview {
    ContentView()
}
