import SwiftUI

struct ReturnOptionsView: View {
    @ObservedObject var viewModel: TravelSearchViewModel
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        HStack {
            Text("\(viewModel.destination) -> \(viewModel.departure) on: \(viewModel.dateReturnPicked.formatted(date: .numeric, time: .shortened))")
        }
            if (viewModel.returnOptions.isEmpty){
                ProgressView() // show loading symbol
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5)
                    .padding()
            }
        else{
            List (viewModel.returnOptions.indices, id: \.self) { option in
                VStack{
                    NavigationLink ("expand", destination: OptionDetailsView(segments: $viewModel.returnOptions[option], viewModel: viewModel, navigationPath: $navigationPath))
                    if let vehicle = viewModel.returnOptions[option].first?.vehicle {
                        Text(vehicle.rawValue)
                    } else {
                        Text("no vehicle!")
                    }
                    Text(viewModel.getOptionDeparture(viewModel.returnOptions[option]))
                    if (viewModel.returnOptions[option].count > 1){
                        if (viewModel.returnOptions[option].count == 3){
                            Text("\(viewModel.returnOptions[option].count - 1) change")
                                .foregroundStyle(.blue)
                        }
                        else {
                            Text("\(viewModel.returnOptions[option].count - 1) changes")
                                .foregroundStyle(.blue)
                        }
                    }
                    Text("price: " + String(format: "%.2f", viewModel.computeTotalPrice(viewModel.returnOptions[option])) + "€")
                        .foregroundStyle(.green)
                    Text("duration: " + viewModel.computeTotalDuration(viewModel.returnOptions[option]))
                    Text("co2: " + String(format: "%.2f", viewModel.computeCo2Emitted(viewModel.returnOptions[option])))
                        .foregroundStyle(.red)
                    Text(viewModel.getOptionDestination(viewModel.returnOptions[option]))
                }
            }
        }
    }
}
