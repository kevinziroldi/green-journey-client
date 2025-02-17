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
                        HeaderView(from: travelDetails.getDepartureSegment()?.departureCity ?? "", to: travelDetails.getDestinationSegment()?.destinationCity ?? "", date: travelDetails.segments.first?.dateTime, dateArrival: travelDetails.segments.last?.getArrivalDateTime())
                    
                    Rectangle()
                        .frame(height: 1)
                        .foregroundStyle(.gray)
                    ScrollView {
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(colorScheme == .dark ? Color(red: 20/255, green: 20/255, blue: 20/255) : Color(red: 235/255, green: 235/255, blue: 235/255))
                                .strokeBorder(
                                    LinearGradient(gradient: Gradient(colors: [.green, .mint, .cyan, .blue]),
                                                   startPoint: .topTrailing, endPoint: .bottomLeading), lineWidth: 4)
                            HStack (spacing: 30){
                                VStack {
                                    ZStack {
                                        SemiCircle()
                                            .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round))
                                            .foregroundColor(.gray.opacity(0.6))
                                            .frame(width: 130, height: 110)
                                        
                                        // semiCircle filled
                                        SemiCircle(progress: progress)
                                            .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round))
                                            .foregroundStyle(LinearGradient(gradient: Gradient(colors: [.red, .orange, .yellow, .green, .mint]), startPoint: .leading, endPoint: .trailing))
                                            .frame(width: 130, height: 110)
                                        
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
                                        Text("  0 Kg       ")
                                        
                                        Text(String(format: "%.1f", travelDetails.computeCo2Emitted()) + " Kg")
                                    }
                                    .font(.headline)
                                    
                                    
                                }
                                .padding(EdgeInsets(top: 0, leading: 15, bottom: 15, trailing: 0))
                                
                                if (travelDetails.computeCo2Emitted() > 0.0 && travelDetails.travel.CO2Compensated < travelDetails.computeCo2Emitted()) {
                                    VStack {
                                        Spacer()
                                        Text("Compensation")
                                            .font(.title2)
                                            .foregroundStyle(.green.opacity(0.8))
                                            .fontWeight(.semibold)
                                        Spacer()
                                        HStack {
                                            Spacer()
                                            Text("\(plantedTrees) / \(totalTrees)")
                                                .padding(.top, 5)
                                                .font(.headline)
                                            Image(systemName: "tree")
                                                .font(.title2)
                                            
                                            Button(action: {
                                                infoTapped = true
                                            }) {
                                                Image(systemName: "info.circle")
                                                    .foregroundStyle(.gray)
                                            }
                                            Spacer()
                                            VStack (spacing: 5) {
                                                Button(action: {
                                                    if plantedTrees < totalTrees {
                                                        plantedTrees += 1
                                                    }
                                                }) {
                                                    Image(systemName: "plus.circle")
                                                        .foregroundStyle(.black)
                                                }
                                                Button(action: {
                                                    if plantedTrees > 0 {
                                                        plantedTrees -= 1
                                                    }
                                                }) {
                                                    Image(systemName: "minus.circle")
                                                        .foregroundStyle(.black)
                                                }
                                            }
                                            
                                        }
                                        .padding(.trailing, 15)
                                        HStack {
                                            Text("Price: \(plantedTrees * 15) €")
                                        }
                                        Spacer()
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
                                                .padding(5)
                                            }
                                            .fixedSize()
                                        }
                                        .padding(.bottom, 15)
                                    }
                                }
                            }
                        }
                        .padding(EdgeInsets(top: 5, leading: 15, bottom: 5, trailing: 15))
                        
                        TravelRecapView(travelDetails: travelDetails)
                            .padding(.horizontal)
                            
                        
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
                        HStack {
                            Text(travelDetails.isOneway() ? "Segments" : "Outward")
                                .font(.title)
                                .fontWeight(.semibold)
                            Spacer()
                            
                                Button(action: {
                                    showAlert = true
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
                                                await viewModel.deleteTravel(travelToDelete: travelDetails.travel)
                                                navigationPath.removeLast()
                                            }
                                        }
                                    )
                            }
                        }
                        .padding(.horizontal, 15)
                        
                        SegmentsView(segments: travelDetails.getOutwardSegments())
                        
                        if !travelDetails.isOneway() {
                            HStack {
                                Text("Return")
                                    .font(.title)
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                            .padding()
                            SegmentsView(segments: travelDetails.getReturnSegments())
                        }
                    }
                    .padding(10)
                    
                    Spacer()
                }
                .blur(radius: (infoTapped) ? 2 : 0)
                .allowsHitTesting(!infoTapped)
                
                if infoTapped {
                    InfoCompensationView(onBack: {infoTapped = false})
                }
            }
            .background(colorScheme == .dark ? Color(red: 10/255, green: 10/255, blue: 10/255) : Color(red: 245/255, green: 245/255, blue: 245/255))
            .onAppear() {
                if (travelDetails.computeCo2Emitted() > 0.0 && travelDetails.travel.CO2Compensated < travelDetails.computeCo2Emitted()) {
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
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 10)
        .frame(width: 330, height: 500)
    }
}
