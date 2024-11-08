import SwiftUI

struct TravelOptionsView: View {
    @ObservedObject var viewModel: FromToViewModel
    
    var body: some View {
        HStack {
            Text("\(viewModel.departure) -> \(viewModel.destination) on: \(viewModel.datePicked.formatted(date: .numeric, time: .shortened))")
        }
        NavigationStack {
            if (viewModel.outwardOptions.isEmpty){
                ProgressView() // show loading symbol
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5)
                        .padding()
            }
            else{
                List (viewModel.outwardOptions.indices, id: \.self) { option in
                    VStack{
                        NavigationLink ("expand", destination: OptionDetailsView(segments: viewModel.outwardOptions[option], viewModel: viewModel))
                        if let vehicle = viewModel.outwardOptions[option].first?.vehicle {
                            Text(vehicle.rawValue)
                        } else {
                            Text("no vehicle!")
                        }
                        
                        Text(viewModel.getOptionDeparture(viewModel.outwardOptions[option]))
                        if (viewModel.outwardOptions[option].count > 1){
                            if (viewModel.outwardOptions[option].count == 2){
                                Text("\(viewModel.outwardOptions[option].count) change")
                                    .foregroundStyle(.blue)
                            }
                            else {
                                Text("\(viewModel.outwardOptions[option].count) changes")
                                    .foregroundStyle(.blue)
                            }
                        }
                        Text("price: " + String(format: "%.2f", viewModel.computeTotalPrice(viewModel.outwardOptions[option])) + "€")
                            .foregroundStyle(.green)
                        Text("duration: " + viewModel.computeTotalDuration(viewModel.outwardOptions[option]))
                        Text("co2: " + String(format: "%.2f", viewModel.computeCo2Emitted(viewModel.outwardOptions[option])))
                            .foregroundStyle(.red)
                        Text(viewModel.getOptionDestination(viewModel.outwardOptions[option]))
                    }
                }
            }
        }
    }
}

