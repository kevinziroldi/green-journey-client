//
//  TravelOptionsView.swift
//  GreenJourney
//
//  Created by matteo volpari on 15/10/24.
//
import SwiftUI

struct TravelOptionsView: View {
    @ObservedObject var viewModel: FromToViewModel
    @State var isNavigationActive: Bool = false
    
    var body: some View {
        HStack {
            Text("\(viewModel.departure) -> \(viewModel.destination) on: \(viewModel.datePicked.formatted(date: .numeric, time: .shortened))")
        }
        VStack{
            if let outwardOptions = viewModel.outwardOptions {
                List {
                    ForEach(outwardOptions.indices, id: \.self) { option in
                        if let vehicle = outwardOptions[option].first?.vehicle {
                            Text(vehicle.rawValue)
                        } else {
                            Text("no vehicle!")
                        }
                        VStack{
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
            }
            else {
                Text("No options")
            }
            HStack {
                Text("proceed")
            }
        }
    }
}

