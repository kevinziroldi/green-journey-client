import SwiftUI

struct TravelCardView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    let travelDetails: TravelDetails
    @EnvironmentObject var viewModel: MyTravelsViewModel
    @Environment(\.colorScheme) var colorScheme: ColorScheme

    var body: some View {
        if horizontalSizeClass == .compact {
            // iOS
            
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(computeTravelColor(travel: travelDetails), lineWidth: 5)
                    .fill(computeTravelBackColor(travel: travelDetails))
                
                VStack {
                    HStack{
                        // vehicles
                        VehiclesView(oneWay: travelDetails.isOneway(), outwardVehicle: travelDetails.findVehicle(outwardDirection: true), returnVehicle: travelDetails.findVehicle(outwardDirection: false))
                            .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0))
                        Spacer()
                        // departure and destination with dates
                        DepartureDestinationAllDatesInfoView(travelDetails: travelDetails)
                        Spacer()
                        // travel direction
                        VStack {
                            DirectionTagView(direction: travelDetails.isOneway())
                            Spacer()
                        }
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
                            .scaleEffect(1.5)
                            .padding(.bottom, 5)
                            .padding(.trailing, 10)
                        Text("Compensation:" )
                        Text(String(format: "%.1f", travelDetails.travel.CO2Compensated) + " / " + String(format: "%.1f", travelDetails.computeCo2Emitted()) + " Kg")
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
                RoundedRectangle(cornerRadius: 20)
                    .stroke(computeTravelColor(travel: travelDetails), lineWidth: 5)
                    .fill(computeTravelBackColor(travel: travelDetails))
                
                HStack {
                    VStack {
                        // vehicles
                        VehiclesView(oneWay: travelDetails.isOneway(), outwardVehicle: travelDetails.findVehicle(outwardDirection: true), returnVehicle: travelDetails.findVehicle(outwardDirection: false))
                        Spacer()
                        // direction tag
                        DirectionTagView(direction: travelDetails.isOneway())
                    }
                    .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0))
                    
                    Spacer()
                    
                    // departure and destination with dates
                    DepartureDestinationAllDatesInfoView(travelDetails: travelDetails)
                    
                    Spacer()
                    
                    VStack {
                        Image(systemName: "carbon.dioxide.cloud")
                            .font(.title)
                            .scaleEffect(1.5)
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 5, trailing: 0))
                        Text("Co2 compensation")
                        Text(String(format: "%.1f/%.1f kg", travelDetails.travel.CO2Compensated, travelDetails.computeCo2Emitted()))
                    }
                    
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
    
    func computeTravelColor(travel : TravelDetails) -> LinearGradient {
        let co2Emitted = travel.computeCo2Emitted()
        let distance = travel.computeTotalDistance()
        if co2Emitted == 0.0 {
            return LinearGradient(colors: [.green.opacity(0.7), .blue.opacity(0.7)], startPoint: .bottomLeading, endPoint: .topTrailing)
        }
        if travel.travel.CO2Compensated >= travel.computeCo2Emitted() {
            return LinearGradient(colors: [.green.opacity(0.7), .blue.opacity(0.7)], startPoint: .bottomLeading, endPoint: .topTrailing)
        }
        if distance/co2Emitted > 30 {
            return AppColors.ecoGreenTravel
        }
        if distance/co2Emitted > 20 {
            return AppColors.ecoYellowTravel
        }
        return AppColors.ecoRedTravel
    }
    
    func computeTravelBackColor(travel: TravelDetails) -> LinearGradient{
        if travel.travel.CO2Compensated >= travel.computeCo2Emitted() {
            return LinearGradient(colors: [.green.opacity(0.3), .blue.opacity(0.3)], startPoint: .bottomLeading, endPoint: .topTrailing)
        }
        else {
            return LinearGradient(colors: [.clear], startPoint: .bottomLeading, endPoint: .topTrailing)
        }
    }
}

struct VehiclesView: View {
    var oneWay: Bool
    var outwardVehicle: String
    var returnVehicle: String
    
    var body: some View {
        VStack {
            ZStack{
                Circle()
                    .stroke(lineWidth: 2)
                    .frame(width: 45, height: 45)
                Image(systemName: outwardVehicle)
                    .font(.title2)
            }
            if !oneWay {
                ZStack{
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

struct DepartureDestinationAllDatesInfoView: View {
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
            .scaledToFit()
            .minimumScaleFactor(0.7)
            HStack{
                Text(travelDetails.getOutwardSegments().first?.dateTime.formatted(date: .numeric, time: .omitted) ?? "")
                    .font(.subheadline)
                    .fontWeight(.light)
                /*Text("-")
                    .font(.subheadline)
                let arrivalDate = travelDetails.getOutwardSegments().last?.getArrivalDateTime()
                Text(arrivalDate?.formatted(date: .numeric, time: .omitted) ?? "")
                    .font(.subheadline)
                    .fontWeight(.light)*/
            }
            .scaledToFit()
            .minimumScaleFactor(0.7)
            if horizontalSizeClass == .regular {
                ZStack {
                    let changesOut = travelDetails.countChanges(outwardDirection: true)
                    if (changesOut > 1){
                        if (changesOut == 2){
                            Text("\(changesOut) change")
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
                .scaledToFit()
                .minimumScaleFactor(0.7)
                HStack{
                    Text(travelDetails.getReturnSegments().first?.dateTime.formatted(date: .numeric, time: .omitted) ?? "")
                        .font(.subheadline)
                        .fontWeight(.light)
                    /*Text("-")
                        .font(.subheadline)
                    let arrivalDate = travelDetails.getReturnSegments().last?.getArrivalDateTime()
                    Text(arrivalDate?.formatted(date: .numeric, time: .omitted) ?? "")
                        .font(.subheadline)
                        .fontWeight(.light)*/
                }
                .scaledToFit()
                .minimumScaleFactor(0.7)
                if horizontalSizeClass == .regular {
                    ZStack {
                        let changesRet = travelDetails.countChanges(outwardDirection: false)
                        if (changesRet > 1){
                            if (changesRet == 2){
                                Text("\(changesRet) change")
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
    }
}

struct DirectionTagView: View {
    var direction: Bool

    var body: some View {
        ZStack {
            /*RoundedRectangle(cornerRadius: 20)
                .stroke()
            if direction {
                Text("One way")
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(5)
            }
            else {
                Text("Round trip")
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(5)
            }*/
        }
        .fixedSize()
    }
}
