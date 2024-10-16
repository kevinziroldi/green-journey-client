//
//  FromToView.swift
//  GreenJourney
//
//  Created by matteo volpari on 10/10/24.
//

import SwiftUI
import MapKit

struct FromToView: View {
    @StateObject private var viewModel = FromToViewModel(userId:1)
    @FocusState private var isDepartureFocused: Bool
    @FocusState private var isDestinationFocused: Bool
    @State private var isNavigationActive: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack{
                    VStack{
                        TextField("insert a departure", text: $viewModel.departure)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .focused($isDepartureFocused)
                            .padding(15)
                            .onTapGesture {
                                isDepartureFocused = true
                            }
                        if isDepartureFocused && !viewModel.suggestions.isEmpty {
                            List(viewModel.suggestions, id: \.self) { suggestion in
                                VStack(alignment: .leading) {
                                    Text(suggestion.title)
                                        .font(.headline)
                                    Text(suggestion.subtitle)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                .padding(.vertical, 4)
                                .onTapGesture {
                                    viewModel.departure = suggestion.title
                                    isDepartureFocused = false
                                }
                            }
                            .listStyle(PlainListStyle())
                            .frame(maxHeight: 250)
                            .cornerRadius(10)
                            .padding([.leading, .trailing], 16)
                        }
                    }
                    Spacer()
                    
                    VStack{
                        
                        TextField("insert a destination", text: $viewModel.destination)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .focused($isDestinationFocused)
                            .padding(15)
                            .onTapGesture {
                                isDestinationFocused = true
                            }
                        if isDestinationFocused && !viewModel.suggestions.isEmpty {
                            List(viewModel.suggestions, id: \.self) { suggestion in
                                VStack(alignment: .leading) {
                                    Text(suggestion.title)
                                        .font(.headline)
                                    Text(suggestion.subtitle)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                .padding(.vertical, 4)
                                .onTapGesture {
                                    viewModel.destination = suggestion.title
                                    isDestinationFocused = false
                                }
                            }
                            .listStyle(PlainListStyle())
                            .frame(maxHeight: 250)
                            .cornerRadius(10)
                            .padding([.leading, .trailing], 16)
                        }
                    }
                    Spacer()
                    HStack {
                        Button ("one way") {
                            if (!viewModel.oneWay) {
                                viewModel.oneWay = true
                            }
                        }
                        .foregroundColor(viewModel.oneWay ? Color.red : Color.secondary)
                        
                        Button ("return") {
                            if (viewModel.oneWay) {
                                viewModel.oneWay = false
                            }
                        }
                        .foregroundColor(viewModel.oneWay ? Color.secondary : Color.red)
                    }
                    DatePicker("andata",selection: $viewModel.datePicked)
                        .padding(15)
                    if (!viewModel.oneWay) {
                        DatePicker("ritorno",selection: $viewModel.dateReturnPicked)
                            .padding(15)
                    }
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Button ("compute"){
                        viewModel.computeRoutes(from: viewModel.departure, to: viewModel.destination, on: viewModel.datePicked)
                        isNavigationActive = true
                    }
                    .navigationDestination(isPresented: $isNavigationActive) {
                        TravelOptionsView(viewModel: viewModel)
                    }
                }
            }
        }
    }
}
#Preview {
    FromToView()
}
