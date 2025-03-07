import SwiftUI

struct OptionCardView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var option: [Segment]
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var viewModel: TravelSearchViewModel
    
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 20)
                .stroke(computeTravelColor(option: option), lineWidth: 5)
                .fill(colorScheme == .dark ? Color(red: 48/255, green: 48/255, blue: 48/255) : Color.clear)
            
            if horizontalSizeClass == .compact {
                // iOS
                
                VStack {
                    // top part
                    HStack {
                        Image(systemName: viewModel.findVehicle(option))
                            .font(.title2)
                            .padding(EdgeInsets(top: -20, leading: 10, bottom: 0, trailing: 0))
                        
                        Spacer()
                        
                        DepartureDestinationInfoView(departureDate: option.first?.dateTime, departure: viewModel.getOptionDeparture(option), destinationDate: option.last?.getArrivalDateTime(), destination: viewModel.getOptionDestination(option), changes: viewModel.countChanges(option))
                        
                        Spacer()
                        
                        Co2CloudView(co2Value: viewModel.computeCo2Emitted(option))
                        
                        Spacer()
                        
                        // arrow symbol
                        Image(systemName: "chevron.forward")
                            .font(.title2)
                            .foregroundStyle(.blue)
                    }
                    
                    // horizontal line
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.gray)
                    
                    // bottom part
                    HStack{
                        Spacer()
                        
                        Image(systemName: "clock")
                            .font(.title3)
                            .padding(EdgeInsets(top: 7, leading: 0, bottom: 5, trailing: 0))
                        Text(viewModel.computeTotalDuration(option))
                        
                        Spacer()
                        
                        Text("Price: " + String(format: "%.2f", viewModel.computeTotalPrice(option)) + "€")
                            .foregroundStyle(.green)
                        Spacer()
                    }
                }
                .padding()
            } else {
                // iPadOS
                
                HStack {
                    // vehicle
                    Image(systemName: viewModel.findVehicle(option))
                        .font(.title2)
                        .padding(.leading, 10)
                    
                    Spacer()
                    
                    // general info
                    VStack {
                        DepartureDestinationInfoView(departureDate: option.first?.dateTime, departure: viewModel.getOptionDeparture(option), destinationDate: option.last?.getArrivalDateTime(), destination: viewModel.getOptionDestination(option), changes: viewModel.countChanges(option))
                        
                        HStack {
                            Image(systemName: "clock")
                                .font(.title3)
                                .padding(.top, 5)
                            Text(viewModel.computeTotalDuration(option))
                        }
                    }
                    
                    Spacer()
                    
                    // prices
                    OptionPriceView(basePrice: viewModel.computeTotalPrice(option), greenPrice: viewModel.computeGreenPrice(option))
                    
                    Spacer()
                    
                    // co2 emission
                    Co2CloudView(co2Value: viewModel.computeCo2Emitted(option))
                    
                    Spacer()
                    
                    // arrow symbol
                    Image(systemName: "chevron.forward")
                        .font(.title2)
                        .foregroundStyle(.blue)
                }
                .padding()
            }
        }
        .padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10))
        
    }
    
    func computeTravelColor(option : [Segment]) -> LinearGradient {
        var co2Emitted = 0.0
        var distance = 0.0
        for segment in option {
            distance += segment.distance
            co2Emitted += segment.co2Emitted
        }
        if co2Emitted == 0.0 {
            return AppColors.ecoGreenTravel
        }
        if distance/co2Emitted > 30 {
            return AppColors.ecoGreenTravel
        }
        if distance/co2Emitted > 20 {
            return AppColors.ecoYellowTravel
        }
        return AppColors.ecoRedTravel
    }
}

struct DepartureDestinationInfoView: View {
    var departureDate: Date?
    var departure: String
    var destinationDate: Date?
    var destination: String
    var changes: Int
    
    var body: some View {
        VStack{
            Text(departureDate?.formatted(date: .numeric, time: .shortened) ?? "")
                .font(.subheadline)
                .fontWeight(.light)
                .scaledToFit()
                .minimumScaleFactor(0.6)
                .lineLimit(1)
            Text(departure)
                .font(.title3)
                .scaledToFit()
                .minimumScaleFactor(0.6)
                .lineLimit(1)
            ZStack {
                if (changes > 1){
                    if (changes == 2){
                        Text("\(changes) change")
                            .foregroundStyle(.blue)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    else {
                        Text("\(changes - 1) changes")
                            .foregroundStyle(.blue)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                 }
            }
            Text(destination)
                .font(.title3)
                .scaledToFit()
                .minimumScaleFactor(0.6)
                .lineLimit(1)
            
            Text(destinationDate?.formatted(date: .numeric, time: .shortened) ?? "")
                .font(.subheadline)
                .fontWeight(.light)
                .scaledToFit()
                .minimumScaleFactor(0.6)
                .lineLimit(1)
        }
    }
}

struct OptionPriceView: View {
    var basePrice: Float64
    var greenPrice: Float64
    
    var body: some View {
        VStack {
            Text("Base price: " + String(format: "%.2f", basePrice) + "€")
            
            Text("Green price: " + String(format: "%.2f", greenPrice) + "€")
                .foregroundStyle(.green)
        }
    }
}

struct Co2CloudView: View {
    var co2Value: Float64
    
    var body: some View {
        VStack {
            Image(systemName: "carbon.dioxide.cloud")
                .font(.title)
                .scaleEffect(1.5)
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 5, trailing: 0))
            Text(String(format: "%.2f", co2Value) + " Kg")
        }
    }
}
