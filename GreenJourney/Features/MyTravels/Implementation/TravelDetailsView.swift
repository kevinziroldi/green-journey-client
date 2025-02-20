import SwiftUI

struct TravelDetailsView: View {
    @ObservedObject var viewModel: MyTravelsViewModel
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @Binding var navigationPath: NavigationPath
    @State var compensationTapped: Bool = false
    @State var infoTapped: Bool = false
    @State var progress: Float64 = 0
    @State var showAlert = false
    @State var plantedTrees = 0
    @State var totalTrees = 0
    
    var body : some View {
        if let travelDetails = viewModel.selectedTravel {
            ZStack {
                VStack (spacing:0){
                    
                    
                    ScrollView {
                        HeaderView(from: travelDetails.getDepartureSegment()?.departureCity ?? "", to: travelDetails.getDestinationSegment()?.destinationCity ?? "", date: travelDetails.segments.first?.dateTime, dateArrival: travelDetails.segments.last?.getArrivalDateTime())
                            .accessibilityElement(children: .contain)
                            .overlay(Color.clear.accessibilityIdentifier("headerView"))
                        
                        Rectangle()
                            .frame(height: 1)
                            .foregroundStyle(.gray)
                        if travelDetails.travel.confirmed {
                            ZStack {
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color(uiColor: .systemBackground))
                                    .strokeBorder(
                                        LinearGradient(gradient: Gradient(colors: [.blue, .cyan, .mint, .green]),
                                                       startPoint: .topTrailing, endPoint: .bottomLeading), lineWidth: 6)
                                    .shadow(color: .green.opacity(0.3), radius: 5, x: 0, y: 3)

                                    HStack{
                                        VStack {
                                            Text("Compensation")
                                                .font(.title)
                                                .foregroundStyle(.green.opacity(0.8))
                                                .padding(EdgeInsets(top: 15, leading: 15, bottom: 10, trailing: 0))
                                                .fontWeight(.semibold)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                            if (travelDetails.computeCo2Emitted() > 0.0 && travelDetails.travel.CO2Compensated < travelDetails.computeCo2Emitted()) {
                                                VStack (spacing: 0){
                                                    HStack {
                                                        VStack (spacing: 10) {
                                                            Button(action: {
                                                                if plantedTrees < totalTrees {
                                                                    plantedTrees += 1
                                                                }
                                                            }) {
                                                                Image(systemName: "plus.circle")
                                                                    .font(.system(size: 24))
                                                                    .fontWeight(.light)
                                                                    .foregroundStyle(colorScheme == .dark ? .white : .black)

                                                            }
                                                            .disabled(plantedTrees == totalTrees)
                                                            .accessibilityIdentifier("plusButton")
                                                            
                                                            Button(action: {
                                                                if plantedTrees > 0 {
                                                                    plantedTrees -= 1
                                                                }
                                                            }) {
                                                                Image(systemName: "minus.circle")
                                                                    .font(.system(size: 24))
                                                                    .fontWeight(.light)
                                                                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                                                            }
                                                            .disabled(plantedTrees==viewModel.getPlantedTrees(travelDetails))
                                                            .accessibilityIdentifier("minusButton")
                                                        }
                                                        .padding(.leading)
                                                        
                                                        Spacer()
                                                        
                                                        Text("\(plantedTrees) / \(totalTrees)")
                                                            .font(.system(size: 25))
                                                        Image(systemName: "tree")
                                                            .font(.system(size: 25))
                                                            .padding(.bottom, 5)
                                                        
                                                        Button(action: {
                                                            infoTapped = true
                                                        }) {
                                                            Image(systemName: "info.circle")
                                                                .foregroundStyle(.gray)
                                                                .font(.title3)
                                                        }
                                                        .accessibilityIdentifier("infoButton")
                                                        .id("infoButton")
                                                        
                                                        Spacer()
                                                    }
                                                    .padding(.trailing, 15)
                                                    
                                                    Text("Price: \(plantedTrees * 2) €")
                                                        .padding()
                                                        .font(.system(size: 17))
                                                                                                        
                                                    Button(action: {
                                                        compensationTapped = true
                                                    }) {
                                                        ZStack {
                                                            RoundedRectangle(cornerRadius: 30)
                                                                .fill(.green)
                                                                .stroke(Color(red: 1/255, green: 150/255, blue: 1/255), lineWidth: 2)
                                                            HStack (spacing: 3) {
                                                                Image(systemName: "leaf")
                                                                    .font(.title3)
                                                                    .fontWeight(.semibold)
                                                                    .fontWeight(.light)
                                                                    .foregroundStyle(.white)
                                                                Text("Compensate")
                                                                    .foregroundStyle(.white)
                                                                    .fontWeight(.semibold)
                                                            }
                                                            .padding(10)
                                                        }
                                                        .fixedSize()
                                                    }
                                                    .padding(.bottom, 15)
                                                    .accessibilityIdentifier("compensateButton")
                                                }
                                                .padding(.top, 10)
                                            }
                                            else {
                                                VStack {
                                                    HStack (spacing: 0){
                                                        Text("you planted: \(plantedTrees)")
                                                            .font(.system(size: 20))
                                                        Image(systemName: "tree")
                                                            .font(.system(size: 20))
                                                            .padding(.bottom, 5)
                                                    }
                                                    .padding()
                                                    
                                                    Text("Thank you 🌍")
                                                        .font(.system(size: 18))
                                                        .fontWeight(.light)
                                                    
                                                        .padding()
                                                }
                                            }
                                        }
                                        VStack {
                                            ZStack {
                                                SemiCircle()
                                                    .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round))
                                                    .foregroundColor(.gray.opacity(0.6))
                                                    .frame(width: 140, height: 110)
                                                
                                                // semiCircle filled
                                                SemiCircle(progress: progress)
                                                    .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round))
                                                    .foregroundStyle(LinearGradient(gradient: Gradient(colors: [.red, .orange, .yellow, .green, .mint]), startPoint: .leading, endPoint: .trailing))
                                                    .frame(width: 140, height: 110)
                                                
                                                VStack (spacing: 15){
                                                    Image(systemName: "carbon.dioxide.cloud")
                                                        .font(.largeTitle)
                                                        .scaleEffect(1.5)
                                                    Text(String(format: "%.0f", progress * 100) + "%")
                                                        .font(.headline)
                                                        .fontWeight(.bold)
                                                }
                                                .foregroundStyle(computeColor(progress))
                                                
                                            }
                                            .padding(.top, 30)
                                            
                                            HStack {
                                                Text(" 0 Kg       ")
                                                Text(String(format: "%.1f", travelDetails.computeCo2Emitted()) + " Kg")
                                            }
                                            .padding(.bottom, 5)
                                            .font(.headline)
                                        }
                                        
                                    }
                                    .padding(.trailing, 25)
                                
                                .accessibilityElement(children: .contain)
                                .overlay(Color.clear.accessibilityIdentifier("compensationSection"))
                            }
                            .padding(EdgeInsets(top: 5, leading: 15, bottom: 5, trailing: 15))
                        }
                        else {
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
                                        Text("Emission: " + String(format: "%.1f", travelDetails.computeCo2Emitted()) + " Kg")
                                        Spacer()
                                        Text("#\(viewModel.getNumTrees(travelDetails))")
                                        Image(systemName: "tree")
                                    }
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .padding()
                                    .foregroundStyle(Color(hue: 0.309, saturation: 1.0, brightness: 0.665).opacity(1))
                                }
                            }
                            .padding(EdgeInsets(top: 10, leading: 15, bottom: 5, trailing: 15))
                            .accessibilityElement(children: .contain)
                            .overlay(Color.clear.accessibilityIdentifier("emissionsRecapFutureTravel"))
                        }
                        
                        TravelRecapView(travelDetails: travelDetails)
                            .padding(.horizontal)
                            .accessibilityElement(children: .contain)
                            .overlay(Color.clear.accessibilityIdentifier("travelRecap"))
                        if travelDetails.travel.confirmed {
                        // if the user hasn't left a review yet
                        Button(action: {
                            //review
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke()
                                    .frame(width: 90, height: 30)
                                Text("Review")
                                    .padding()
                            }
                        }
                        .accessibilityIdentifier("reviewButton")
                    }
                        
                        HStack {
                            Text(travelDetails.isOneway() ? "Segments" : "Outward")
                                .font(.title)
                                .fontWeight(.semibold)
                                .accessibilityIdentifier("segmentsTitle")
                            Spacer()
                            
                            Button(action: {
                                showAlert = true
                                viewModel.selectedTravel = travelDetails
                            }) {
                                Image(systemName: "trash.circle")
                                    .font(.largeTitle)
                                    .scaleEffect(1.2)
                                    .fontWeight(.light)
                                    .foregroundStyle(.red)
                            }
                            .alert(isPresented: $showAlert) {
                                Alert(
                                    title: Text("Delete this travel?"),
                                    message: Text("you cannot undo this action"),
                                    primaryButton: .cancel(Text("Cancel")) {},
                                    secondaryButton: .destructive(Text("Delete")) {
                                        //delete travel
                                        Task {
                                            await viewModel.deleteTravel()
                                            navigationPath.removeLast()
                                        }
                                    }
                                )
                            }
                            .accessibilityIdentifier("trashButton")
                        }
                        .padding(.horizontal, 15)
                        
                        SegmentsView(segments: travelDetails.getOutwardSegments())
                            .accessibilityElement(children: .contain)
                            .overlay(Color.clear.accessibilityIdentifier("outwardSegmentsView"))
                        
                        if !travelDetails.isOneway() {
                            HStack {
                                Text("Return")
                                    .font(.title)
                                    .fontWeight(.semibold)
                                    .accessibilityIdentifier("returnTitle")
                                Spacer()
                            }
                            .padding()
                            
                            SegmentsView(segments: travelDetails.getReturnSegments())
                                .accessibilityElement(children: .contain)
                                .overlay(Color.clear.accessibilityIdentifier("returnSegmentsView"))
                        }
                    }
                    .padding(10)
                    
                    Spacer()
                }
                .blur(radius: (infoTapped) ? 2 : 0)
                .allowsHitTesting(!infoTapped)
                
                if infoTapped {
                    InfoCompensationView(onBack: {infoTapped = false})
                        .accessibilityIdentifier("infoCompensationView")
                }
            }
            .background(colorScheme == .dark ? Color(red: 10/255, green: 10/255, blue: 10/255) : Color(red: 245/255, green: 245/255, blue: 245/255))
            .onAppear() {
                if (travelDetails.computeCo2Emitted() >= 0.0) {
                    if (travelDetails.travel.CO2Compensated >= travelDetails.computeCo2Emitted()) {
                        progress = 1.0
                    }
                    else {
                        progress = travelDetails.travel.CO2Compensated / travelDetails.computeCo2Emitted()
                    }
                    totalTrees = viewModel.getNumTrees(travelDetails)
                    plantedTrees = viewModel.getPlantedTrees(travelDetails)
                }
            }
        }
    }
}

func computeColor(_ progress: Double) -> Color {
    if progress >= 0.9 {
        return Color.mint
    }
    else if progress >= 0.7 {
        return Color.green
    }
    else if progress >= 0.5 {
        return Color.yellow
    }
    else if progress >= 0.3 {
        return Color.orange
    }
    else {
        return Color.red
    }
}

struct SemiCircle: Shape {
    var progress: Double = 1.0
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let startAngle = Angle(degrees: 135)
        let endAngle = Angle(degrees: 135 + 270 * progress)
        
        path.addArc(
            center: CGPoint(x: rect.midX, y: rect.midY),
            radius: rect.width / 2,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: false
        )
        return path
    }
}

struct InfoCompensationView: View {
    var onBack: () -> Void
    var body: some View {
        VStack {
            Text("""
                long
text
legend compensation
""")
            Button("Close") {
                onBack()
            }
            .accessibilityIdentifier("infoCloseButton")
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 10)
        .frame(width: 330, height: 500)
    }
}
