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
                        path.move(to: CGPoint(x: 0, y: 10))
                        
                        path.addLine(to: CGPoint(x: 0, y: geometry.size.height - 10))
                    }
                    .stroke(colorScheme == .dark ? Color.white : Color.black, lineWidth: 3)
                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                    Circle()
                        .stroke(colorScheme == .dark ? Color.white : Color.black, lineWidth: 5)
                        .fill(colorScheme == .dark ? Color.black : Color.white)
                        .frame(width: 10, height: 10)
                        .position(x: 0, y: 10)
                    
                    Circle()
                        .stroke(colorScheme == .dark ? Color.white : Color.black, lineWidth: 5)
                        .fill(colorScheme == .dark ? Color.black : Color.white)
                        .frame(width: 10, height: 10)
                        .position(x: 0, y: geometry.size.height - 10)
                }
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            }
            .frame(width: 20)
            .accessibilityIdentifier("segmentLine")
            
            HStack{
                VStack {
                    HStack{
                        Text(segment.departureCity)
                            .frame(width: 130, alignment: .leading)
                            .font(.headline)
                            .accessibilityIdentifier("segmentDeparture")
                        Text(segment.dateTime.formatted(date: .numeric, time: .shortened))
                            .font(.callout)
                            .fontWeight(.light)
                            .accessibilityIdentifier("departureDate")
                            .scaledToFit()
                            .minimumScaleFactor(0.6)
                            .lineLimit(1)
                        Spacer()
                    }
                    .border(.black)
                    
                    HStack {
                        ZStack{
                            Circle()
                                .stroke(lineWidth: 2.5)
                                .frame(width: 40, height: 40)
                            Image(systemName: segment.findVehicle())
                                .font(.title2)
                        }
                        .overlay(Color.clear.accessibilityIdentifier("vehicleImage"))
                        
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
                        .accessibilityIdentifier("openDetailsButton")
                        
                        Spacer()
                    }
                    .border(.black)
                    
                    if detailsOpen {
                        if segment.segmentDescription != "" {
                            HStack {
                                VStack {
                                    HStack (spacing: 5) {
                                        VStack{
                                            Text("Info:")
                                                .font(.subheadline)
                                                .fontWeight(.bold)
                                            Spacer()
                                        }
                                        VStack {
                                            Text(segment.segmentDescription)
                                                .font(.subheadline)
                                            Spacer()
                                        }
                                    }
                                }
                                .overlay(Color.clear.accessibilityIdentifier("segmentInfo"))
                                
                                Spacer()
                            }
                            .padding(.vertical, 5)
                            .border(.black)
                        }
                    }
                    if detailsOpen {
                        VStack {
                            HStack {
                                ZStack {
                                    Circle()
                                        .fill(.indigo.opacity(0.2))
                                        .frame(width: 40, height: 40)
                                    
                                    Image(systemName: "road.lanes")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 25, height: 25)
                                        .foregroundColor(.indigo)
                                }
                                Text("Distance")
                                    .foregroundStyle(.indigo)
                                    .frame(width: 80, alignment: .leading)
                                    .padding(.leading)
                                Text(String(format: "%.1f", segment.distance) + " Km")
                                    .foregroundStyle(.indigo)
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                            HStack {
                                ZStack {
                                    Circle()
                                        .fill(.green.opacity(0.2))
                                        .frame(width: 40, height: 40)
                                    
                                    Image("price_green")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(.green)
                                }
                                
                                Text("Price")
                                    .frame(width: 80, alignment: .leading)
                                    .foregroundStyle(.green)
                                    .padding(.leading)
                                Text(String(format: "%.2f", segment.price) + " €")
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.green)
                                Spacer()
                            }
                            HStack {
                                
                                ZStack {
                                    Circle()
                                        .fill(.red.opacity(0.2))
                                        .frame(width: 40, height: 40)
                                    
                                    Image(systemName: "carbon.dioxide.cloud")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 25, height: 25)
                                        .foregroundColor(.red)
                                }
                                
                                Text("Emission")
                                    .frame(width: 80, alignment: .leading)
                                    .foregroundStyle(.red)
                                    .padding(.leading)
                                Text(String(format: "%.1f", segment.co2Emitted) + " Kg CO2")
                                    .foregroundStyle(.red)
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                        }
                        .border(.black)
                        .overlay(Color.clear.accessibilityIdentifier("detailsBox"))
                    }
                    
                    Spacer()
                    HStack {
                        Text(segment.destinationCity)
                            .frame(width: 130, alignment: .leading)
                            .font(.headline)
                            .accessibilityIdentifier("segmentDestination")
                        
                        Text(segment.getArrivalDateTime().formatted(date: .numeric, time: .shortened))
                            .font(.callout)
                            .fontWeight(.light)
                            .accessibilityIdentifier("arrivalDate")
                            .scaledToFit()
                            .minimumScaleFactor(0.6)
                            .lineLimit(1)
                        Spacer()
                    }
                    .border(.black)
                }
                Spacer()
            }
        }
        .border(.black)
        .padding(.horizontal, 30)
        .padding(.vertical, 5)
    }
}
