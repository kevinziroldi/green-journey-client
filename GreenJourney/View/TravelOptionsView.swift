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
                List {
                    ForEach(outwardOptions.indices, id: \.self) { option in
                        if let vehicle = outwardOptions[option].first?.vehicle {
                            Text(vehicle.rawValue)
                        } else {
                            Text("no vehicle!")
                        }
                        HStack {
                            ForEach(outwardOptions[option], id: \.id) { segment in
                                VStack {
                                    Text(segment.departure)
                                    Text(segment.destination)
                                    Text(segment.co2Emitted.formatted())
                                    Text(segment.duration.formatted())
                                }
                            }
                        }
                    }
                }
            }
            else {
                Text("No options")
            }
        }
    }
}

