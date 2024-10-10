//
//  HomeVIew.swift
//  GreenJourney
//
//  Created by matteo volpari on 10/10/24.
//

import SwiftUI

struct HomeView: View {
    @State private var homeViewModel = HomeViewModel()
    @State var datepicked = Date.now
    @State var departure: String
    @State var destination: String
    var body: some View {
        VStack{
            
            TextField("insert a departure", text: $departure)
            TextField("insert a destination", text: $destination)
            DatePicker("select a date",selection: $datepicked)
            Button ("compute"){
                homeViewModel.computeRoutes(from:departure, to:destination, on:datepicked)
            }
        }
    }
}
