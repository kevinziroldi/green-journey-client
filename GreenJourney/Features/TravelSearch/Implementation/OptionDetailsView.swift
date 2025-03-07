import SwiftUI

struct OptionDetailsView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    var option: TravelOption
    @ObservedObject var viewModel: TravelSearchViewModel
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        HeaderView(from: option.getOptionDeparture(), to: option.getOptionDestination(), date: option.segments.first?.dateTime)
        
        Rectangle()
            .frame(height: 1)
            .foregroundColor(.gray)
        
        if horizontalSizeClass == .compact {
            // iOS
            
            ScrollView {
                Co2RecapView(halfWidth: false, co2Emitted: option.getCo2Emitted(), numTrees: option.getNumTrees(), distance: option.getTotalDistance())
                    .padding(EdgeInsets(top: 10, leading: 15, bottom: 5, trailing: 15))
                    .overlay(Color.clear.accessibilityIdentifier("co2EmittedBox"))
                
                TravelRecapView(distance: option.getTotalDistance(), duration: option.getTotalDuration(), price: option.getTotalPrice(), greenPrice: option.getGreenPrice())
                    .padding()
                    .overlay(Color.clear.accessibilityIdentifier("travelRecap"))
                
                SegmentsView(segments: option.segments)
                    .padding(.top)
                
                Spacer()
            }
        } else {
            // iPadOS
            
            ScrollView {
                HStack {
                    Co2RecapView(halfWidth: true, co2Emitted: option.getCo2Emitted(), numTrees: option.getNumTrees(), distance: option.getTotalDistance())
                        .padding(EdgeInsets(top: 10, leading: 15, bottom: 5, trailing: 15))
                        .overlay(Color.clear.accessibilityIdentifier("co2EmittedBox"))
                    
                    TravelRecapView(distance: option.getTotalDistance(), duration: option.getTotalDuration(), price: option.getTotalPrice(), greenPrice: option.getGreenPrice())
                        .padding()
                        .overlay(Color.clear.accessibilityIdentifier("travelRecap"))
                }
                
                SegmentsView(segments: option.segments)
                    .padding(.top)
                
                Spacer()
            }
        }
        
        if (!viewModel.oneWay) {
            if (viewModel.selectedOption.isEmpty) {
                Button (action: {
                    viewModel.selectedOption.append(contentsOf: option.segments)
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
                        viewModel.selectedOption.append(contentsOf: option.segments)
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
                    viewModel.selectedOption.append(contentsOf: option.segments)
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

