//
//  OptionDetailsView.swift
//  GreenJourney
//
//  Created by matteo volpari on 18/10/24.
//
import SwiftUI

struct OptionDetailsView: View {
    let segments: [Segment]
    @ObservedObject var viewModel: FromToViewModel
    @State var isReturnOptionsViewPresented = false
    @State var isFromToViewPresented = false

    var body: some View {
        NavigationStack {
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
                        Spacer()
                        Text("to: " + segment.destination)
                        Spacer()
                        Text("departure: " + segment.date.formatted(date: .numeric, time: .shortened))
                        let arrival = segment.date.addingTimeInterval(TimeInterval(segment.duration / 1000000000))
                        Text("arrival: " + arrival.formatted(date: .numeric, time: .shortened))
                        Spacer()
                        Text("info: " + segment.description)
                        Text("cost: " + String(format: "%.2f", segment.price) + "€")
                        Text("distance: " + String(format: "%.2f", segment.distance) + "km")
                    }
                }
            }
            if (!viewModel.oneWay) {
                if (viewModel.selectedOption.isEmpty) {
                    Button ("proceed"){
                        viewModel.selectedOption.append(contentsOf: segments)
                        isReturnOptionsViewPresented = true
                    }
                    .navigationDestination(isPresented: $isReturnOptionsViewPresented) {
                        ReturnOptionsView(viewModel: viewModel)
                    }
                }
                else {
                    Button ("save travel") {
                        viewModel.selectedOption.append(contentsOf: segments)
                        //viewModel.saveTravel      todo
                        isFromToViewPresented = true
                    }
                    .navigationDestination(isPresented: $isFromToViewPresented) {
                        FromToView()
                    }
                    .navigationTitle("Details")
                }
            }
            else {
                Button ("save travel") {
                    viewModel.selectedOption.append(contentsOf: segments)
                    isFromToViewPresented = true
                    //viewModel.saveTravel()        todo
                }
                .navigationDestination(isPresented: $isFromToViewPresented) {
                    FromToView()
                }
                .navigationTitle("Details")
            }
        }
    }
}
