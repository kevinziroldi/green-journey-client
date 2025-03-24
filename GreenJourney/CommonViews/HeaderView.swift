import SwiftUI

struct HeaderView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    var from: String
    var to: String
    var date: Date?
    var dateArrival: Date?
    var body: some View {
        
        if horizontalSizeClass == .compact {
            //IOS
                VStack (spacing: 5){
                    HStack {
                        Text("From")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(.gray)
                            .frame(width: UIScreen.main.bounds.width/2 - 30)
                            .accessibilityIdentifier("fromTravelHeader")
                        Text("To")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(.gray)
                            .frame(width: UIScreen.main.bounds.width/2 - 30)
                            .accessibilityIdentifier("toTravelHeader")
                    }
                    HStack {
                        Text(from)
                            .font(.system(size: 23, weight: .semibold))
                            .frame(width: UIScreen.main.bounds.width/2 - 30)
                        Text(to)
                            .font(.system(size: 23, weight: .semibold))
                            .frame(width: UIScreen.main.bounds.width/2 - 30)
                    }
                    ZStack {
                        HStack{
                            if dateArrival != nil{
                                Divider()
                                    .frame(height: 40)
                            }
                        }
                        HStack {
                            if let date = date {
                                VStack(spacing: 5) {
                                    Text("Departure")
                                        .font(.system(size: 13, weight: .regular))
                                        .foregroundColor(.gray)
                                        .frame(width: UIScreen.main.bounds.width/2 - 30)
                                    
                                    Text(date.formatted(date: .abbreviated, time: .shortened))
                                        .accessibilityIdentifier("departureDate")
                                        .font(.system(size: 14, weight: .regular))
                                        .frame(width: UIScreen.main.bounds.width/2 - 30)
                                }
                            }
                            if let dateArrival = dateArrival {
                                VStack(spacing: 5) {
                                    Text("Arrival")
                                        .font(.system(size: 13, weight: .regular))
                                        .foregroundColor(.gray)
                                        .frame(width: UIScreen.main.bounds.width/2 - 30)
                                    
                                    Text(dateArrival.formatted(date: .abbreviated, time: .shortened))
                                        .font(.system(size: 14, weight: .regular))
                                        .accessibilityIdentifier("arrivalDate")
                                        .frame(width: UIScreen.main.bounds.width/2 - 30)
                                }
                            }
                        }
                    }
                    .padding(.top, 5)
                }
                    

        }
        else {
            //iPadOS
            VStack (spacing: 0){
                HStack {
                    Text(from)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .scaledToFit()
                        .lineLimit(2)
                        .minimumScaleFactor(0.5)
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
                        .scaledToFit()
                        .lineLimit(2)
                        .minimumScaleFactor(0.5)
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
}
