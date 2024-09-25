//
//  ContentView.swift
//  GreenJourney
//
//  Created by Kevin Ziroldi on 25/09/24.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var continent: String = "Asia"
    @State private var temperature: String = "high_temp"
    @State private var population: String = "high_pop"
    @State private var city: String = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Continent: ")
                TextField("Enter Continent", text: $continent)
                
                Text("Temperature: ")
                TextField("Enter temperature", text: $temperature).textInputAutocapitalization(.never)
                
                Text("Population: ")
                TextField("Enter population", text: $population).textInputAutocapitalization(.never)
                
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
            let model = try GreenJourneyClassifier(configuration: config)
            let prediction = try model.prediction(average_temperature: temperature, population: population, continent: continent)
            city = prediction.city
        }catch{
            city = "error"
        }
    }
}

#Preview {
    ContentView()
}
