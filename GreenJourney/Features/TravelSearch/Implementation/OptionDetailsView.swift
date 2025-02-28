import SwiftUI

struct OptionDetailsView: View {
    var segments: [Segment]

    @ObservedObject var viewModel: TravelSearchViewModel
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        HeaderView(from: getOptionDeparture(segments), to: getOptionDestination(segments), date: segments.first?.dateTime)
        
        Rectangle()
            .frame(height: 1)
            .foregroundColor(.gray)
        
        ScrollView {
            
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color(uiColor: .systemBackground))
                    .shadow(color: Color(hue: 0.309, saturation: 1.0, brightness: 0.665).opacity(0.3), radius: 5, x: 0, y: 3)
                VStack (spacing:0){
                    Text("Co2")
                        .font(.title)
                        .foregroundStyle(Color(hue: 0.309, saturation: 1.0, brightness: 0.665).opacity(0.8))
                        .padding(EdgeInsets(top: 15, leading: 15, bottom: 0, trailing: 0))
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack {
                        Text("Emission: " + String(format: "%.1f", viewModel.computeCo2Emitted(segments)) + " Kg")
                        Spacer()
                        Text("#\(viewModel.getNumTrees(segments))")
                        Image(systemName: "tree")
                    }
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding()
                    .foregroundStyle(Color(hue: 0.309, saturation: 1.0, brightness: 0.665).opacity(1))
                }
            }
            .padding(EdgeInsets(top: 10, leading: 15, bottom: 5, trailing: 15))
            .overlay(Color.clear.accessibilityIdentifier("co2EmittedBox"))
            
            TravelRecapView(distance: viewModel.computeTotalDistance(segments), duration: viewModel.computeTotalDuration(segments), price: viewModel.computeTotalPrice(segments), greenPrice: viewModel.computeGreenPrice(segments))
                .padding()
                
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
            Button ("Save travel") {
                Task {
                    viewModel.selectedOption.append(contentsOf: segments)
                    await viewModel.saveTravel()
                    navigationPath = NavigationPath()
                }
            }
            .buttonStyle(.borderedProminent)
            .accessibilityIdentifier("saveTravelButtonOneWay")
        }
    }
    
    func getOptionDeparture (_ travelOption: [Segment]) -> String {
        if let firstSegment = travelOption.first {
            return firstSegment.departureCity
        }
        else {
            return ""
        }
    }
    
    func getOptionDestination (_ travelOption: [Segment]) -> String {
        if let lastSegment = travelOption.last {
            return lastSegment.destinationCity
        }
        else {
            return ""
        }
    }
    func computeCo2Emitted(_ travelOption: [Segment]) -> Float64 {
        var co2Emitted: Float64 = 0.0
        for segment in travelOption {
            co2Emitted += segment.co2Emitted
        }
        return co2Emitted
    }
    
    func computeTotalPrice (_ travelOption: [Segment]) -> Float64 {
        var price: Float64 = 0.0
        for segment in travelOption {
            price += segment.price
        }
        return price
    }
    
    func computeTotalDistance(_ travelOption: [Segment]) -> Float64 {
        var distance: Float64 = 0.0
        for segment in travelOption {
            distance += segment.distance
        }
        return distance
    }
    func computeTotalDuration (_ travelOption: [Segment]) -> String {
        var duration = 0
        for segment in travelOption {
            duration += segment.duration/1000000000
        }
        return UtilitiesFunctions.convertTotalDurationToString(totalDuration: duration)
    }
}

