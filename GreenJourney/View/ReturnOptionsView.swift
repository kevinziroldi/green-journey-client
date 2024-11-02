//
//  ReturnOptionsView.swift
//  GreenJourney
//
//  Created by matteo volpari on 19/10/24.
//
import SwiftUI

struct ReturnOptionsView: View {
    @ObservedObject var viewModel: FromToViewModel
    
    var body: some View {
        HStack {
            Text("\(viewModel.destination) -> \(viewModel.departure) on: \(viewModel.dateReturnPicked.formatted(date: .numeric, time: .shortened))")
        }
        NavigationStack {
            List (viewModel.travelOptions.returnOptions!.indices, id: \.self) { option in
                    VStack{
                        NavigationLink ("expand", destination: OptionDetailsView(segments: viewModel.travelOptions.returnOptions![option], viewModel: viewModel))
                        if let vehicle = viewModel.travelOptions.returnOptions![option].first?.vehicle {
                            Text(vehicle.rawValue)
                        } else {
                            Text("no vehicle!")
                        }
                        Text(viewModel.getOptionDeparture(viewModel.travelOptions.returnOptions![option]))
                        if (viewModel.travelOptions.returnOptions![option].count > 1){
                            if (viewModel.travelOptions.returnOptions![option].count == 2){
                                Text("\(viewModel.travelOptions.returnOptions![option].count) change")
                                    .foregroundStyle(.blue)
                            }
                            else {
                                Text("\(viewModel.travelOptions.returnOptions![option].count) changes")
                                    .foregroundStyle(.blue)
                            }
                        }
                        Text("price: " + String(format: "%.2f", viewModel.computeTotalPrice(viewModel.travelOptions.returnOptions![option])) + "€")
                            .foregroundStyle(.green)
                        Text("duration: " + viewModel.computeTotalDuration(viewModel.travelOptions.returnOptions![option]))
                        Text("co2: " + String(format: "%.2f", viewModel.computeCo2Emitted(viewModel.travelOptions.returnOptions![option])))
                            .foregroundStyle(.red)
                        Text(viewModel.getOptionDestination(viewModel.travelOptions.returnOptions![option]))
                    }
                }
        }
    }
}
