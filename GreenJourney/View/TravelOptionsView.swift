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
        VStack{
            if let outwardOptions = viewModel.outwardOptions {
                VStack {
                    List (outwardOptions.trainOption) { option in
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
                    List (outwardOptions.busOption) { option in
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
                    if let carOption = outwardOptions.carOption {
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
                    if let bikeOption = outwardOptions.bikeOption {
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
                    List (outwardOptions.flightOption) { option in
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
            else {
                Text("no options")
            }
            Button ("Proceed") {
                if viewModel.oneWay {
                    //salva nel db il viaggio selezionato
                    //vai nella pagina viaggi
                }
                else {
                    isNavigationActive = true
                }
            }
            .navigationDestination(isPresented: $isNavigationActive) {
                //TravelOptionsReturnView(viewModel: viewModel)
            }
        }
    }
}

