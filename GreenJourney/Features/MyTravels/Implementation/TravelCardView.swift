import SwiftUI

struct TravelCardView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    let travelDetails: TravelDetails
    
    var body: some View {
        if horizontalSizeClass == .compact {
            // iOS
            
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(computeTravelBackColor())
                    .shadow(radius: 2, x: 0, y: 2)
                
                VStack {
                    HStack {
                        // vehicles
                        VehiclesView(oneWay: travelDetails.isOneway(), outwardVehicle: travelDetails.findVehicle(outwardDirection: true), returnVehicle: travelDetails.findVehicle(outwardDirection: false))
                            .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0))
                        Spacer()
                        // departure and destination with dates
                        DepartureDestinationAllDatesInfoView(travelDetails: travelDetails)
                        Spacer()
                        // travel direction
                        Spacer()
                        Image(systemName: "chevron.forward")
                            .font(.title2)
                            .foregroundStyle(.blue)
                    }
                    
                    // horizontal line
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.gray)
                    
                    // co2 compensation
                    HStack {
                        Image(systemName: "carbon.dioxide.cloud")
                            .font(.title)
                            .padding(.trailing, 10)
                            .foregroundStyle(computeTravelColor())
                        Text("Compensation")
                            .fontWeight(.semibold)
                            .foregroundStyle(computeTravelColor())
                        Text(String(format: "%.1f", travelDetails.travel.CO2Compensated) + " / " + String(format: "%.1f", travelDetails.computeCo2Emitted()) + " Kg")
                            .fontWeight(.semibold)
                            .foregroundStyle(computeTravelColor())
                    }
                    .scaledToFit()
                    .minimumScaleFactor(0.7)
                }
                .padding()
                .foregroundStyle(colorScheme == .dark ? Color.white : Color.black)
            }
            
        } else {
            // iPadOS
            
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(computeTravelBackColor())
                    .shadow(radius: 2, x: 0, y: 2)
                
                HStack {
                    VStack {
                        // vehicles
                        VehiclesView(oneWay: travelDetails.isOneway(), outwardVehicle: travelDetails.findVehicle(outwardDirection: true), returnVehicle: travelDetails.findVehicle(outwardDirection: false))
                        Spacer()
                        // direction tag
                    }
                    .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0))
                    
                    Spacer()
                    
                    // departure and destination with dates
                    DepartureDestinationAllDatesInfoView(travelDetails: travelDetails)
                    
                    Spacer()
                    
                    VStack {
                        Image(systemName: "carbon.dioxide.cloud")
                            .font(.system(size: 40))
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 5, trailing: 0))
                        Text("CO\u{2082} compensation")
                        Text(String(format: "%.1f/%.1f kg", travelDetails.travel.CO2Compensated, travelDetails.computeCo2Emitted()))
                            .fontWeight(.semibold)
                    }
                    .foregroundStyle(computeTravelColor())
                    
                    Spacer()
                    
                    Image(systemName: "chevron.forward")
                        .font(.title2)
                        .foregroundStyle(.blue)
                }
                .padding()
                .foregroundStyle(colorScheme == .dark ? Color.white : Color.black)
            }
        }
    }
    
    func computeTravelColor() -> LinearGradient {
        let co2Emitted = travelDetails.computeCo2Emitted()
        let distance = travelDetails.computeTotalDistance()
        
        if travelDetails.travel.CO2Compensated >= co2Emitted {
            return LinearGradient(colors: [.primary], startPoint: .bottom, endPoint: .top)
        }
        if distance/co2Emitted > 30  {
            return AppColors.ecoGreenTravel
        }
        if distance/co2Emitted > 20 {
            return AppColors.ecoYellowTravel
        }
        return AppColors.ecoRedTravel
    }
    
    func computeTravelBackColor() -> LinearGradient{
        if travelDetails.travel.CO2Compensated >= travelDetails.computeCo2Emitted() {
            return LinearGradient(colors: [Color(red: 153/255, green: 204/255, blue: 153/255), Color(red: 143/255, green: 234/255, blue: 255/255)], startPoint: .bottomLeading, endPoint: .topTrailing)
        }
        else {
            if colorScheme == .dark {
                return LinearGradient(colors: [AppColors.blockColorDark], startPoint: .bottom, endPoint: .top)
            } else {
                return LinearGradient(colors: [Color(uiColor: .systemBackground)], startPoint: .bottom, endPoint: .top)
            }            
        }
    }
}

private struct VehiclesView: View {
    var oneWay: Bool
    var outwardVehicle: String
    var returnVehicle: String
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(lineWidth: 2)
                    .frame(width: 45, height: 45)
                Image(systemName: outwardVehicle)
                    .font(.title2)
            }
            if !oneWay {
                ZStack {
                    Circle()
                        .stroke(lineWidth: 2)
                        .frame(width: 45, height: 45)
                    Image(systemName: returnVehicle)
                        .font(.title2)
                    
                }
            }
        }
    }
}

private struct DepartureDestinationAllDatesInfoView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    var travelDetails: TravelDetails
    
    var body: some View {
        VStack {
            // outward
            HStack (spacing: 10){
                Text(travelDetails.getDepartureSegment()?.departureCity ?? "")
                    .font(.headline)
                Text("-")
                    .font(.headline)
                Text(travelDetails.getDestinationSegment()?.destinationCity ?? "")
                    .font(.headline)
            }
            .frame(width: min(UIScreen.main.bounds.width/2 - 15, 400))
            
            HStack {
                Text(travelDetails.getOutwardSegments().first?.dateTime.formatted(date: .numeric, time: .omitted) ?? "")
                    .font(.subheadline)
                    .fontWeight(.light)
            }
            .frame(width: min(UIScreen.main.bounds.width/2 - 15, 400))
            
            if horizontalSizeClass == .regular {
                ZStack {
                    let changesOut = travelDetails.countChanges(outwardDirection: true)
                    if (changesOut > 1){
                        if (changesOut == 2){
                            Text("1 change")
                                .foregroundStyle(.blue)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                        else {
                            Text("\(changesOut - 1) changes")
                                .foregroundStyle(.blue)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                    }
                }
            }
            
            // return
            if !travelDetails.isOneway() {
                HStack (spacing: 10){
                    Text(travelDetails.getDestinationSegment()?.destinationCity ?? "")
                        .font(.headline)
                    Text("-")
                        .font(.headline)
                    Text(travelDetails.getDepartureSegment()?.departureCity ?? "")
                        .font(.headline)
                }
                .frame(width: min(UIScreen.main.bounds.width/2 - 15, 400))
                .scaledToFit()
                .minimumScaleFactor(0.7)
                HStack {
                    Text(travelDetails.getReturnSegments().first?.dateTime.formatted(date: .numeric, time: .omitted) ?? "")
                        .font(.subheadline)
                        .fontWeight(.light)
                }
                .frame(width: min(UIScreen.main.bounds.width/2 - 15, 400))
                .scaledToFit()
                .minimumScaleFactor(0.7)
                if horizontalSizeClass == .regular {
                    ZStack {
                        let changesRet = travelDetails.countChanges(outwardDirection: false)
                        if (changesRet > 1){
                            if (changesRet == 2){
                                Text("1 change")
                                    .foregroundStyle(.blue)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                            }
                            else {
                                Text("\(changesRet - 1) changes")
                                    .foregroundStyle(.blue)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                }
            }
        }
        .fixedSize()
    }
}
