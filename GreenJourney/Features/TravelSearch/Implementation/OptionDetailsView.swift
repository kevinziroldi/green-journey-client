import SwiftUI

struct OptionDetailsView: View {
    var segments: [Segment]

    @ObservedObject var viewModel: TravelSearchViewModel
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        HeaderView(from: viewModel.getOptionDeparture(segments), to: viewModel.getOptionDestination(segments), date: segments.first?.dateTime)
        
        Rectangle()
            .frame(height: 1)
            .foregroundColor(.gray)
        
        ScrollView {
            
            Co2RecapView(co2Emitted: viewModel.computeCo2Emitted(segments), numTrees: viewModel.getNumTrees(segments), distance: viewModel.computeTotalDistance(segments))
            .padding(EdgeInsets(top: 10, leading: 15, bottom: 5, trailing: 15))
            .overlay(Color.clear.accessibilityIdentifier("co2EmittedBox"))
            
            TravelRecapView(distance: viewModel.computeTotalDistance(segments), duration: viewModel.computeTotalDuration(segments), price: viewModel.computeTotalPrice(segments), greenPrice: viewModel.computeGreenPrice(segments))
                .padding()
                .overlay(Color.clear.accessibilityIdentifier("travelRecap"))
                
            SegmentsView(segments: segments)
                .padding(.top)
            
            Spacer()
        }
        if (!viewModel.oneWay) {
            if (viewModel.selectedOption.isEmpty) {
                Button (action: {
                    viewModel.selectedOption.append(contentsOf: segments)
                    navigationPath.append(NavigationDestination.ReturnOptionsView(viewModel))
                }) {
                    Text("Proceed")
                        .font(.title2)
                }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("proceedButton")
            }
            else {
                Button (action:  {
                    Task {
                        viewModel.selectedOption.append(contentsOf: segments)
                        await viewModel.saveTravel()
                        navigationPath = NavigationPath()
                    }
                }) {
                    Text("Save travel")
                        .font(.title2)
                }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("saveTravelButtonTwoWays")
            }
        }
        else {
            Button (action: {
                Task {
                    viewModel.selectedOption.append(contentsOf: segments)
                    await viewModel.saveTravel()
                    navigationPath = NavigationPath()
                }
            }) {
                Text("Save travel")
                    .font(.title2)
            }
            .buttonStyle(.borderedProminent)
            .accessibilityIdentifier("saveTravelButtonOneWay")
        }
    }
}

