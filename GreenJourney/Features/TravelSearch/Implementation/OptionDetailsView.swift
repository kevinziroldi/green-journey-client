import SwiftUI

struct OptionDetailsView: View {
    @Binding var segments: [Segment]
    @ObservedObject var viewModel: TravelSearchViewModel
    @Environment(\.modelContext) private var modelContext
    @Binding var navigationPath: NavigationPath

    var body: some View {
            if let vehicle = segments.first?.vehicle {
                Text(vehicle.rawValue)
            }
            else {
                Text("no vehicle detected")
            }
            
        List ($segments, id: \.self) { segment in
                    VStack {
                        Text("from: \(segment.departureCity.wrappedValue)" )
                        Spacer()
                        Text("to: \(segment.destinationCity.wrappedValue)")
                        Spacer()
                        
                        Text("departure: \(segment.date.wrappedValue.formatted(date: .numeric, time: .shortened))")
                        let arrival = segment.date.wrappedValue.addingTimeInterval(TimeInterval(segment.duration.wrappedValue / 1000000000))
                        Text("arrival: \(arrival.formatted(date: .numeric, time: .shortened))")
                        Text("vehicle: \(segment.vehicle.wrappedValue.rawValue)")
                        Spacer()
                        Text("info: \(segment.segmentDescription.wrappedValue)")
                        Text("cost: " + String(format: "%.2f", segment.price.wrappedValue) + "€")
                        Text("distance: " + String(format: "%.2f", segment.distance.wrappedValue) + "km")
                }
            }
            
            if (!viewModel.oneWay) {
                if (viewModel.selectedOption.isEmpty) {
                    Button ("proceed"){
                        viewModel.selectedOption.append(contentsOf: segments)
                        navigationPath.append(NavigationDestination.ReturnOptionsView)
                    }
                }
                else {
                    Button ("save travel") {
                        viewModel.selectedOption.append(contentsOf: segments)
                        viewModel.saveTravel()
                        //viewModel.resetParameters()
                        navigationPath = NavigationPath()
                    }
                }
            }
            else {
                Button ("save travel") {
                    viewModel.selectedOption.append(contentsOf: segments)
                    viewModel.saveTravel()
                    //viewModel.resetParameters()
                    navigationPath = NavigationPath()
                }
            }
    }
}
