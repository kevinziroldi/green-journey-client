//
//  TravelOptionsView.swift
//  GreenJourney
//
//  Created by matteo volpari on 15/10/24.
//
import SwiftUI

struct TravelOptionsView: View {
    @ObservedObject var viewModel: FromToViewModel
    
    var body: some View {
        HStack {
            Text("\(viewModel.departure) -> \(viewModel.destination) on: \(viewModel.datePicked.formatted(date: .numeric, time: .shortened))")
        }
        NavigationStack {
            if let outwardOptions = viewModel.outwardOptions {
                List (outwardOptions.indices, id: \.self) { option in
                    VStack{
                        NavigationLink ("expand", destination: OptionDetailsView(segments: outwardOptions[option], viewModel: viewModel))
                        if let vehicle = outwardOptions[option].first?.vehicle {
                            Text(vehicle.rawValue)
                        } else {
                            Text("no vehicle!")
                        }
                        
                        Text(viewModel.getOptionDeparture(outwardOptions[option]))
                        if (outwardOptions[option].count > 1){
                            if (outwardOptions[option].count == 2){
                                Text("\(outwardOptions[option].count) change")
                                    .foregroundStyle(.blue)
                            }
                            else {
                                Text("\(outwardOptions[option].count) changes")
                                    .foregroundStyle(.blue)
                            }
                        }
                        Text("price: " + String(format: "%.2f", viewModel.computeTotalPrice(outwardOptions[option])) + "€")
                            .foregroundStyle(.green)
                        Text("duration: " + viewModel.computeTotalDuration(outwardOptions[option]))
                        Text("co2: " + String(format: "%.2f", viewModel.computeCo2Emitted(outwardOptions[option])))
                            .foregroundStyle(.red)
                        Text(viewModel.getOptionDestination(outwardOptions[option]))
                    }
                }
            }
            else {
                Text("No options")
            }
        }
    }
}

