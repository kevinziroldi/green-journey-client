import SwiftUI

struct OptionCard: View {
    var option: [Segment]
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var viewModel: TravelSearchViewModel
    
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 20)
                .stroke(computeTravelColor(option: option), lineWidth: 5)
                .fill(colorScheme == .dark ? Color(red: 48/255, green: 48/255, blue: 48/255) : Color.white)
            VStack{
                HStack{
                    Image(systemName: viewModel.findVehicle(option))
                        .font(.title2)
                        .padding(EdgeInsets(top: -20, leading: 10, bottom: 0, trailing: 0))
                    Spacer()
                    VStack{
                        
                        Text(option.first?.dateTime.formatted(date: .numeric, time: .shortened) ?? "")
                            .font(.subheadline)
                            .fontWeight(.light)
                        Text(viewModel.getOptionDeparture(option))
                            .font(.title3)
                        ZStack {
                            if (option.count > 1){
                                if (option.count == 2){
                                    Text("\(option.count) change")
                                        .foregroundStyle(.blue)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                }
                                else {
                                    Text("\(option.count - 1) changes")
                                        .foregroundStyle(.blue)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                }
                             }
                        }
                        Text(viewModel.getOptionDestination(option))
                            .font(.title3)
                        
                        let arrivalDate = option.last?.getArrivalDateTime()
                        Text(arrivalDate?.formatted(date: .numeric, time: .shortened) ?? "")
                            .font(.subheadline)
                            .fontWeight(.light)
                        
                    }
                    Spacer()
                    VStack {
                        Image(systemName: "carbon.dioxide.cloud")
                            .font(.title)
                            .scaleEffect(1.5)
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 5, trailing: 0))
                        Text(String(format: "%.2f", viewModel.computeCo2Emitted(option)) + " Kg")
                    }
                    Spacer()
                    Image(systemName: "chevron.forward")
                        .font(.title2)
                        .foregroundStyle(.blue)
                }
                
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.gray)
                HStack{
                    Spacer()
                    Image(systemName: "clock")
                        .font(.title3)
                        .padding(EdgeInsets(top: 7, leading: 0, bottom: 5, trailing: 0))
                    Text(viewModel.computeTotalDuration(option))
                    Spacer()
                    Text("price: " + String(format: "%.2f", viewModel.computeTotalPrice(option)) + "€")
                        .foregroundStyle(.green)
                    Spacer()
                }
            }
            .padding()
        }
        .padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10))
        
    }
    
    func computeTravelColor(option : [Segment]) -> Color {
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
