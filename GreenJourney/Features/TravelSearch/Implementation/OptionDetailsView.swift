import SwiftUI

struct OptionDetailsView: View {
    var segments: [Segment]

    @EnvironmentObject var viewModel: TravelSearchViewModel
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
                Button ("proceed"){
                    viewModel.selectedOption.append(contentsOf: segments)
                    navigationPath.append(NavigationDestination.ReturnOptionsView)
                }
                .buttonStyle(.borderedProminent)

            }
            else {
                Button ("save travel") {
                    viewModel.selectedOption.append(contentsOf: segments)
                    viewModel.saveTravel()
                    viewModel.resetParameters()
                    navigationPath = NavigationPath()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        else {
            Button ("save travel") {
                viewModel.selectedOption.append(contentsOf: segments)
                viewModel.saveTravel()
                viewModel.resetParameters()
                navigationPath = NavigationPath()
            }
            .buttonStyle(.borderedProminent)

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
        var hours: Int = 0
        var minutes: Int = 0
        for segment in travelOption {
            hours += durationToHoursAndMinutes(duration: segment.duration).hours
            minutes += durationToHoursAndMinutes(duration: segment.duration).minutes
        }
        while (minutes >= 60) {
            hours += 1
            minutes -= 60
        }
        return "\(hours) h, \(minutes) min"
    }
    
    func durationToHoursAndMinutes(duration: Int) -> (hours: Int, minutes: Int) {
        let hours = duration / (3600 * 1000000000)       // 1 hour = 3600 secsecondsondi
        let remainingSeconds = (duration / 1000000000) % (3600)
        let minutes = remainingSeconds / 60  // 1 minute = 60 seconds
        
        return (hours, minutes)
    }
}

