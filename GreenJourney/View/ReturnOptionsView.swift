//
//  ReturnOptionsView.swift
//  GreenJourney
//
//  Created by matteo volpari on 19/10/24.
//
import SwiftUI

struct ReturnOptionsView: View {
    let viewModel: FromToViewModel
    
    var body: some View {
        HStack {
            Text("\(viewModel.destination) -> \(viewModel.departure) on: \(viewModel.dateReturnPicked.formatted(date: .numeric, time: .shortened))")
        }
        NavigationStack {
            if let travelOptions = viewModel.travelOptions {
                let returnOptions = travelOptions.returnOptions
                List (returnOptions.indices, id: \.self) { option in
                    VStack{
                        NavigationLink ("expand", destination: OptionDetailsView(segments: returnOptions[option], viewModel: viewModel))
                        if let vehicle = returnOptions[option].first?.vehicle {
                            Text(vehicle.rawValue)
                        } else {
                            Text("no vehicle!")
                        }
                        Text(viewModel.getOptionDeparture(returnOptions[option]))
                        if (returnOptions[option].count > 1){
                            if (returnOptions[option].count == 2){
                                Text("\(returnOptions[option].count) change")
                                    .foregroundStyle(.blue)
                            }
                            else {
                                Text("\(returnOptions[option].count) changes")
                                    .foregroundStyle(.blue)
                            }
                        }
                        Text("price: " + String(format: "%.2f", viewModel.computeTotalPrice(returnOptions[option])) + "€")
                            .foregroundStyle(.green)
                        Text("duration: " + viewModel.computeTotalDuration(returnOptions[option]))
                        Text("co2: " + String(format: "%.2f", viewModel.computeCo2Emitted(returnOptions[option])))
                            .foregroundStyle(.red)
                        Text(viewModel.getOptionDestination(returnOptions[option]))
                    }
                }
            }
            else {
                Text("No options")
            }
        }
    }
}
