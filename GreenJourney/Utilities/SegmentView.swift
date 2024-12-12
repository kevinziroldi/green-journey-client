import SwiftUI

struct SegmentsView: View {
    var segments: [Segment]
    
    var body: some View {
        ForEach(segments) { segment in
            SegmentDetailView(segment: segment)
        }
        
    }
}

struct SegmentDetailView: View {
    var segment: Segment
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @State private var detailsOpen: Bool = false
    @State private var lenght: CGFloat = 85
    @State private var arrowImage: String = "chevron.right"
    var body: some View {
        HStack{
            GeometryReader { geometry in
                ZStack {
                    Path { path in
                        // Punto iniziale in alto a sinistra
                        path.move(to: CGPoint(x: 0, y: 10))
                        
                        path.addLine(to: CGPoint(x: 0, y: geometry.size.height - 10))
                    }
                    .stroke(colorScheme == .dark ? Color.white : Color.black, lineWidth: 3) // Stile tratteggiato
                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black) // Colore della linea
                    Circle()
                        .stroke(colorScheme == .dark ? Color.white : Color.black, lineWidth: 5)
                        .fill(colorScheme == .dark ? Color.black : Color.white)
                        .frame(width: 10, height: 10)
                        .position(x: 0, y: 10)
                    
                    // Cerchio alla fine del path
                    Circle()
                        .stroke(colorScheme == .dark ? Color.white : Color.black, lineWidth: 5)
                        .fill(colorScheme == .dark ? Color.black : Color.white)
                        .frame(width: 10, height: 10)
                        .position(x: 0, y: geometry.size.height - 10)
                }
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            }
            .frame(width: 20, height: lenght)
            
            HStack{
                VStack {
                    Text(segment.departureCity)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.headline)
                    if !detailsOpen{
                        Spacer()
                    }
                    HStack {
                        ZStack{
                            Circle()
                                .stroke(lineWidth: 2.5)
                                .frame(width: 40, height: 40)
                            Image(systemName: findVehicle(segment))
                                .font(.title2)
                            
                        }
                        
                        Button(action: {
                            detailsOpen.toggle()
                            if arrowImage == "chevron.right" {
                                arrowImage = "chevron.down"
                                lenght = 250
                            }
                            else {
                                arrowImage = "chevron.right"
                                lenght = 85
                            }
                        }) {
                            Image(systemName: arrowImage)
                                .font(.title2)
                        }
                        
                        Spacer()
                    }
                    if detailsOpen {
                        Spacer()
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(lineWidth: 1)
                                
                            VStack{
                                Text(String(format: "%.1f", segment.distance) + " Km")
                                    .font(.callout)
                                    .fontWeight(.semibold)
                                    .padding(EdgeInsets(top: 10, leading: 10, bottom: 5, trailing: 10))
                                Rectangle()
                                    .frame(height: 1)
                                Text(String(format: "%.2f", segment.price) + " €")
                                    .font(.callout)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.green)
                                    .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                                Rectangle()
                                    .frame(height: 1)
                                Text(String(format: "%.1f", segment.co2Emitted) + " Kg CO2")
                                    .font(.callout)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.red)
                                    .padding(EdgeInsets(top: 5, leading: 10, bottom: 10, trailing: 10))
                            }
                        }
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    }
                    Spacer()
                    Text(segment.destinationCity)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.headline)
                }
                Spacer()
            }
            
            VStack {
                Text(segment.dateTime.formatted(date: .numeric, time: .shortened))
                    .font(.callout)
                    .fontWeight(.light)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                if detailsOpen {
                    VStack{
                        Spacer()
                        HStack (spacing: 5){
                            VStack{
                                Text("Info:")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                Spacer()
                            }
                            VStack{
                                Text(segment.segmentDescription)
                                    .font(.subheadline)
                                Spacer()
                            }
                        }
                        
                        Spacer()
                    }
                }
                Spacer()
                Text(segment.getArrivalDateTime().formatted(date: .numeric, time: .shortened))
                    .font(.callout)
                    .fontWeight(.light)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
            }
            Spacer()
            Spacer()
        }
        .padding(.horizontal, 30)
        .padding(.vertical, 5)
    }
    func findVehicle(_ segment: Segment) -> String {
        var vehicle: String
        switch segment.vehicle {
        case .car:
            vehicle = "car"
        case .train:
            vehicle = "tram"
        case .plane:
            vehicle = "airplane"
        case .bus:
            vehicle = "bus"
        case .walk:
            vehicle = "figure.walk"
        case .bike:
            vehicle = "bicycle"
        }
        return vehicle
    }
}
