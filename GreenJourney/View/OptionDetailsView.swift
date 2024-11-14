import SwiftUI

struct OptionDetailsView: View {
    let segments: [Segment]
    @ObservedObject var viewModel: FromToViewModel
    @State var isReturnOptionsViewPresented = false
    @State var isFromToViewPresented = false
    @Environment(\.modelContext) private var modelContext
    @Binding var navigationPath: NavigationPath
    @Environment(\.dismiss) private var dismiss

    var body: some View {
            if let vehicle = segments.first?.vehicle {
                Text(vehicle.rawValue)
            }
            else {
                Text("no vehicle detected")
            }
            
            /*List {
                ForEach (segments) { segment in
                    VStack {
                        Text("from: " + segment.departure)
                        Spacer()
                        Text("to: " + segment.destination)
                        Spacer()
                        Text("departure: " + segment.date.formatted(date: .numeric, time: .shortened))
                        let arrival = segment.date.addingTimeInterval(TimeInterval(segment.duration / 1000000000))
                        Text("arrival: " + arrival.formatted(date: .numeric, time: .shortened))
                        Spacer()
                        Text("info: " + segment.description)
                        Text("cost: " + String(format: "%.2f", segment.price) + "€")
                        Text("distance: " + String(format: "%.2f", segment.distance) + "km")
                    }
                }
            }*/
            
            if (!viewModel.oneWay) {
                if (viewModel.selectedOption.isEmpty) {
                    Button ("proceed"){
                        viewModel.selectedOption.append(contentsOf: segments)
                        isReturnOptionsViewPresented = true
                    }
                    .navigationDestination(isPresented: $isReturnOptionsViewPresented) {
                        ReturnOptionsView(viewModel: viewModel, navigationPath: $navigationPath)
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
