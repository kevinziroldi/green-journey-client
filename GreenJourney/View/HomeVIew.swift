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
    

    var body: some View {
        VStack{
            
            TextField("insert a departure", text: $homeViewModel.departure)
            List(homeViewModel.suggestions, id: \.self) { suggestion in
                VStack(alignment: .leading) {
                    Text(suggestion.title)
                        .font(.headline)
                    Text(suggestion.subtitle)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .onTapGesture {
                    homeViewModel.departure = suggestion.title
                    
                }
            }
            
            TextField("insert a destination", text: $homeViewModel.destination)
            List(homeViewModel.suggestions, id: \.self) { suggestion in
                VStack(alignment: .leading) {
                    Text(suggestion.title)
                        .font(.headline)
                    Text(suggestion.subtitle)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .onTapGesture {
                    homeViewModel.destination = suggestion.title
                }
            }
            
            DatePicker("select a date",selection: $homeViewModel.datePicked)
            Button ("compute"){
                homeViewModel.computeRoutes(from: homeViewModel.departure, to: homeViewModel.destination, on:homeViewModel.datePicked)
            }
            
            
        }
    }
}
#Preview {
    HomeView()
}
