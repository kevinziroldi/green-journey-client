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
            HStack {
                VStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.black, lineWidth: 2)
                            .frame(maxWidth: .infinity, maxHeight: 100)
                            .shadow(radius: 10)
                        
                        VStack{
                            Text("Distance")
                                .font(.headline)
                                .padding(.bottom, 5)
                            HStack {
                                Image(systemName: "road.lanes")
                                    .font(.title)
                                Text(String(format: "%.1f", computeTotalDistance(segments)) + " Km")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                
                            }
                        }
                        .padding()
                    }
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.black, lineWidth: 2)
                            .frame(maxWidth: .infinity, maxHeight: 100)
                            .shadow(radius: 10)
                        
                        VStack{
                            Text("Price")
                                .font(.headline)
                                .padding(.bottom, 5)
                            HStack {
                                Image(systemName: "eurosign.bank.building")
                                    .font(.title)
                                    .foregroundStyle(.red)
                                Text(String(format: "%.1f", computeTotalPrice(segments)) + " €")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                            }
                        }
                        .padding()
                    }
                }
                
                VStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.black, lineWidth: 2)
                            .frame(maxWidth: .infinity, maxHeight: 100)
                            .shadow(radius: 10)
                        
                        VStack {
                            Text("Duration")
                                .font(.headline)
                                .padding(.bottom, 5)
                            HStack{
                                Image(systemName: "clock")
                                    .font(.title)
                                    .foregroundStyle(.cyan)
                                Text(computeTotalDuration(segments))
                                    .font(.title3)
                                    .fontWeight(.semibold)
                            }
                        }
                        .padding()
                    }
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.black, lineWidth: 2)
                            .frame(maxWidth: .infinity, maxHeight: 100)
                            .shadow(radius: 10)
                        
                        VStack{
                            Text("Price 0-emission")
                                .font(.headline)
                                .padding(.bottom, 5)
                            HStack {
                                Image(systemName: "eurosign.bank.building")
                                    .font(.title)
                                    .foregroundStyle(.green)
                                Text(String(format: "%.1f", computeTotalPrice(segments)) + " €")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                            }
                        }
                        .padding()
                    }
                }
            }
            .padding(EdgeInsets(top: 10, leading: 10, bottom: 20, trailing: 10))
            HStack (spacing: 50){
                VStack {
                    Text("Total CO2 emitted")
                        .font(.headline)
                        .padding(.bottom, 5)
                    Text(String(format: "%.1f", computeCo2Emitted(segments)) + " Kg")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                Image(systemName: "tree.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.red)
            }
            .padding(.bottom, 30)
            
            SegmentsView(segments: segments)
            Spacer()
        }
        if (!viewModel.oneWay) {
            if (viewModel.selectedOption.isEmpty) {
                Button ("Proceed"){
                    viewModel.selectedOption.append(contentsOf: segments)
                    navigationPath.append(NavigationDestination.ReturnOptionsView(viewModel))
                }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("proceedButton")

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

