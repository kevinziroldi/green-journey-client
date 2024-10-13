//
//  HomeVIew.swift
//  GreenJourney
//
//  Created by matteo volpari on 10/10/24.
//

import SwiftUI
import MapKit

struct HomeView: View {
    @StateObject var homeViewModel = HomeViewModel(userId:1)
    @FocusState var isDepartureFocused: Bool
    @FocusState var isDestinationFocused: Bool
    
    var body: some View {
        ZStack {
            VStack{
                VStack{
                    TextField("insert a departure", text: $homeViewModel.departure)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .focused($isDepartureFocused)
                        .padding(15)
                        .onTapGesture {
                            isDepartureFocused = true
                        }
                    if isDepartureFocused && !homeViewModel.suggestions.isEmpty {
                        List(homeViewModel.suggestions, id: \.self) { suggestion in
                            VStack(alignment: .leading) {
                                Text(suggestion.title)
                                    .font(.headline)
                                Text(suggestion.subtitle)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 4)
                            .onTapGesture {
                                homeViewModel.departure = suggestion.title
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
                    
                    TextField("insert a destination", text: $homeViewModel.destination)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .focused($isDestinationFocused)
                        .padding(15)
                        .onTapGesture {
                            isDestinationFocused = true
                        }
                    if isDestinationFocused && !homeViewModel.suggestions.isEmpty {
                        List(homeViewModel.suggestions, id: \.self) { suggestion in
                            VStack(alignment: .leading) {
                                Text(suggestion.title)
                                    .font(.headline)
                                Text(suggestion.subtitle)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 4)
                            .onTapGesture {
                                homeViewModel.destination = suggestion.title
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
                DatePicker("select a date",selection: $homeViewModel.datePicked)
                    .padding(15)
                Spacer()
                Button ("compute"){
                    homeViewModel.computeRoutes(from: homeViewModel.departure, to: homeViewModel.destination, on:homeViewModel.datePicked)
                }
            }
        }
    }
}
#Preview {
    HomeView()
}
