import SwiftUI

struct HeaderView: View {
    var from: String
    var to: String
    var date: Date?
    var dateArrival: Date?
    var body: some View {
        VStack (spacing: 0){
                    HStack {
                    Text(from)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.horizontal, 5)
                        .accessibilityIdentifier("fromTravelHeader")
                    
                    GeometryReader { geometry in
                        ZStack {
                            Path { path in
                                path.move(to: CGPoint(x: 0, y: geometry.size.height/2))
                                
                                path.addQuadCurve(
                                    to: CGPoint(x: geometry.size.width, y: geometry.size.height/2),
                                    control: CGPoint(x: geometry.size.width/2, y: -15)
                                )
                            }
                            .stroke(style: StrokeStyle(lineWidth: 4, dash: [15, 8]))
                            .foregroundColor(.primary)
                            Circle()
                                .stroke(Color.black, lineWidth: 5)
                                .fill(Color.white)
                                .frame(width: 10, height: 10)
                                .position(x: geometry.size.width, y: geometry.size.height/2)
                            
                            Circle()
                                .stroke(Color.black, lineWidth: 5)
                                .fill(Color.white)
                                .frame(width: 10, height: 10)
                                .position(x: 0, y: geometry.size.height/2)
                        }
                    }
                    .frame(minWidth: 100, maxHeight: 50, alignment: .top)
                    .accessibilityIdentifier("fromToLine")
                    
                    Text(to)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 5)
                        .accessibilityIdentifier("toTravelHeader")
                }
            
            
            HStack {
                if let date = date {
                    Text(date.formatted(date: .numeric, time: .shortened))
                        .accessibilityIdentifier("departureDate")
                }
                
                if let dateArrival = dateArrival {
                    Text("  ->  ")
                    Text(dateArrival.formatted(date: .numeric, time: .shortened))
                        .accessibilityIdentifier("arrivalDate")
                }
            }
            .padding(.bottom, 5)
        }
    }
}



