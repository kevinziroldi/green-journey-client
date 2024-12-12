import SwiftUI

struct TravelDetailsView: View {
    @EnvironmentObject var viewModel: MyTravelsViewModel
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @Binding var navigationPath: NavigationPath
    @State var compensationTapped: Bool = false
    @State var progress: Float64 = 0
    @State var showAlert = false
    
    var body : some View {
        if let travelDetails = viewModel.selectedTravel {
            
            ZStack {
                VStack (spacing:0){
                    ZStack{
                        HeaderView(from: travelDetails.getDepartureSegment()?.departureCity ?? "", to: travelDetails.getDestinationSegment()?.destinationCity ?? "", date: travelDetails.segments.first?.dateTime, dateArrival: travelDetails.segments.last?.getArrivalDateTime())
                            HStack{
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
                                            viewModel.deleteTravel(travelToDelete: travelDetails.travel)
                                        }
                                    )
                                }
                                
                            }
                            .padding(EdgeInsets(top: 0, leading: 15, bottom: 120, trailing: 15))
                    }
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
                            
                                .padding(10)
                            HStack {
                                VStack {
                                    ZStack {
                                        SemiCircle()
                                            .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round))
                                            .foregroundColor(.gray.opacity(0.6))
                                            .frame(width: 130, height: 110)
                                        
                                        
                                        // Semicerchio riempito (colorato)
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
                                    
                                    if (travelDetails.computeCo2Emitted() > 0.0 && travelDetails.travel.CO2Compensated < travelDetails.computeCo2Emitted()) {
                                        
                                        Button(action: {
                                            compensationTapped = true
                                        }) {
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 30)
                                                    .fill(.green)
                                                    .stroke(Color(red: 1/255, green: 150/255, blue: 1/255), lineWidth: 2)
                                                HStack (spacing: 3) {
                                                    Image(systemName: "plus.circle")
                                                        .font(.title)
                                                        .fontWeight(.semibold)
                                                        .fontWeight(.light)
                                                        .foregroundStyle(.white)
                                                    Text("Compensate")
                                                        .foregroundStyle(.white)
                                                        .fontWeight(.semibold)
                                                }
                                                .padding(8)
                                            }
                                            .fixedSize()
                                        }
                                        
                                        
                                    }
                                }
                                .padding(EdgeInsets(top: 0, leading: 15, bottom: 15, trailing: 0))
                                Spacer()
                                Text("Compensation: price/totale")
                            }
                            .padding(10)
                        }
                        
                        
                        
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
                            Text("Outward")
                                .font(.title)
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        .padding(.horizontal, 15)
                        SegmentsView(segments: travelDetails.getOutwardSegments())
                        //if roundtrip
                        
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
                    Spacer()
                }
                .blur(radius: (compensationTapped) ? 2 : 0)
                .allowsHitTesting(!compensationTapped)
                
                if compensationTapped {
                    CompensationView(co2Emitted: 10, progress: progress, onConfirm: { compensation in
                        progress = compensation
                        
                        compensationTapped = false
                    }, onBack: {
                        compensationTapped = false
                    })
                }
            }
            .background(colorScheme == .dark ? Color(red: 10/255, green: 10/255, blue: 10/255) : Color(red: 245/255, green: 245/255, blue: 245/255))
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

struct CompensationView: View {
    var co2Emitted: Float64
    @State var progress: Float64
    
    var onConfirm: (Float64) -> Void
    var onBack: () -> Void
    var body: some View {
        VStack {
            Text("compensate")
            Text(String(format: "%.0f", progress * 100) + "%")
            
            //slider
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Barra di sfondo
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 15)
                    
                    // Barra di progresso
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.green)
                        .frame(width: max(0, min(CGFloat(progress) * geometry.size.width, geometry.size.width)), height: 15) // Assicura valori validi
                    
                    // Thumb personalizzato
                    Circle()
                        .fill(Color(red: 1/255, green: 150/255, blue: 1/255))
                        .frame(width: 25, height: 25)
                        .position(x: max(0, min(CGFloat(progress) * geometry.size.width, geometry.size.width)), y: geometry.size.height / 2) // Assicura valori validi
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    let width = geometry.size.width
                                    if width > 0 { // Protezione contro divisione per zero
                                        let locationX = max(0, min(value.location.x, width)) // Limita il drag ai bordi della barra
                                        progress = Double(locationX / width) // Aggiorna il valore dello slider
                                    }
                                }
                        )
                }
            }
            .frame(height: 40)
            
            
            HStack {
                Text("Compensation price: " + String(format: "%.2f", co2Emitted * progress) + "€")
            }
            HStack (spacing: 80){
                Button(action: {
                    onBack()
                }){
                    Text("Back")
                }
                .buttonStyle(.bordered)
                Button(action: {
                    onConfirm(progress)
                }){
                    Text("Confirm")
                }
                .buttonStyle(.bordered)
            }
            
            
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 10)
        .frame(width: 330, height: 500)
    }
}



