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
                    .padding()
                
                    GeometryReader { geometry in
                        ZStack {
                        Path { path in
                            // Punto iniziale in alto a sinistra
                            path.move(to: CGPoint(x: 0, y: geometry.size.height/2))
                            
                            path.addQuadCurve(
                                to: CGPoint(x: geometry.size.width, y: geometry.size.height/2),
                                control: CGPoint(x: geometry.size.width/2, y: 0)
                            )
                        }
                        .stroke(style: StrokeStyle(lineWidth: 4, dash: [15, 8])) // Stile tratteggiato
                        .foregroundColor(.primary) // Colore della linea
                        Circle()
                                .stroke(Color.black, lineWidth: 5)
                                .fill(Color.white)
                                .frame(width: 10, height: 10)
                            .position(x: geometry.size.width, y: geometry.size.height/2)
                        
                        // Cerchio alla fine del path
                        Circle()
                            .stroke(Color.black, lineWidth: 5)
                            .fill(Color.white)
                            .frame(width: 10, height: 10)
                            .position(x: 0, y: geometry.size.height/2)
                    }
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                }
                    .frame(height: 75, alignment: .top)
                Text(to)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding()
            }
            .padding(.horizontal, 10)
            HStack {
                if let date = date {
                    Text(date.formatted(date: .numeric, time: .shortened))
                }
                if let dateArrival = dateArrival {
                    Text("  ->  ")
                    Text(dateArrival.formatted(date: .numeric, time: .shortened))
                }
            }
            .padding(.bottom, 5)
        }
    }
}

