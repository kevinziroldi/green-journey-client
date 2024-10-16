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
        VStack{
            VStack {
                List (viewModel.trainOption) { option in
                    Text("TRAIN")
                    HStack {
                        List (option.segments) { segment in
                            VStack{
                                Text(segment.departure)
                                Text(segment.destination)
                                Text(segment.duration.formatted())
                            }
                        }
                    }
                }
            }
            VStack {
                List (viewModel.busOption) { option in
                    Text("BUS")
                    HStack {
                        List (option.segments) { segment in
                            VStack {
                                Text(segment.departure)
                                Text(segment.destination)
                                Text(segment.duration.formatted())
                            }
                        }
                    }
                }
            }
            HStack {
                Text("CAR")
                if let carOption = viewModel.carOption {
                        List(carOption.segments) { segment in
                            VStack {
                                Text(segment.departure)
                                Text(segment.destination)
                                Text(segment.duration.formatted())
                            }
                        }
                    } else {
                        Text("No options for car")
                    }
            }
            HStack {
                Text("BIKE")
                if let bikeOption = viewModel.bikeOption {
                    List (bikeOption.segments) { segment in
                        VStack {
                            Text(segment.departure)
                            Text(segment.destination)
                            Text(segment.duration.formatted())
                        }
                    }
                }
            }
            VStack {
                List (viewModel.flightOption) { option in
                    Text("PLANE")
                    HStack {
                        List (option.segments) { segment in
                            VStack{
                                Text(segment.departure)
                                Text(segment.destination)
                                Text(segment.duration.formatted())
                            }
                        }
                    }
                }
            }
            
            
        }
        
    }
}

