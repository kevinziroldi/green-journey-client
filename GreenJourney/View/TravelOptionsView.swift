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
            if (viewModel.travelOptions.outwardOptions.isEmpty || (!viewModel.oneWay && viewModel.travelOptions.returnOptions.isEmpty)){
                Text("NO OPTION")
            }
            else{
                List (viewModel.travelOptions.outwardOptions.indices, id: \.self) { option in
                    VStack{
                        NavigationLink ("expand", destination: OptionDetailsView(segments: viewModel.travelOptions.outwardOptions[option], viewModel: viewModel))
                        if let vehicle = viewModel.travelOptions.outwardOptions[option].first?.vehicle {
                            Text(vehicle.rawValue)
                        } else {
                            Text("no vehicle!")
                        }
                        
                        Text(viewModel.getOptionDeparture(viewModel.travelOptions.outwardOptions[option]))
                        if (viewModel.travelOptions.outwardOptions[option].count > 1){
                            if (viewModel.travelOptions.outwardOptions[option].count == 2){
                                Text("\(viewModel.travelOptions.outwardOptions[option].count) change")
                                    .foregroundStyle(.blue)
                            }
                            else {
                                Text("\(viewModel.travelOptions.outwardOptions[option].count) changes")
                                    .foregroundStyle(.blue)
                            }
                        }
                        Text("price: " + String(format: "%.2f", viewModel.computeTotalPrice(viewModel.travelOptions.outwardOptions[option])) + "€")
                            .foregroundStyle(.green)
                        Text("duration: " + viewModel.computeTotalDuration(viewModel.travelOptions.outwardOptions[option]))
                        Text("co2: " + String(format: "%.2f", viewModel.computeCo2Emitted(viewModel.travelOptions.outwardOptions[option])))
                            .foregroundStyle(.red)
                        Text(viewModel.getOptionDestination(viewModel.travelOptions.outwardOptions[option]))
                    }
                }
            }
        }
    }
}

