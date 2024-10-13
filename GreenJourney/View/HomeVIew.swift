//
//  HomeVIew.swift
//  GreenJourney
//
//  Created by matteo volpari on 10/10/24.
//

import SwiftUI

struct HomeView: View {
    @State private var homeViewModel = HomeViewModel()

    var body: some View {
        VStack{
            
            TextField("insert a departure", text: $homeViewModel.departure)
            TextField("insert a destination", text: $homeViewModel.destination)
            DatePicker("select a date",selection: $homeViewModel.datePicked)
            Button ("compute"){
                homeViewModel.computeRoutes(from: homeViewModel.departure, to: homeViewModel.destination, on:homeViewModel.datePicked)
            }
            
        }
    }
}
