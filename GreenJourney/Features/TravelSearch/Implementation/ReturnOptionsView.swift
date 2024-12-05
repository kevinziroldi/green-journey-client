import SwiftUI

struct ReturnOptionsView: View {
    @EnvironmentObject var viewModel: TravelSearchViewModel
    @Binding var navigationPath: NavigationPath
    var body: some View {
        VStack (spacing: 0){
            HStack {
                Text(viewModel.arrival.cityName)
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
                .frame(width: 180, height: 75, alignment: .top)
                Text(viewModel.departure.cityName)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding()
            }
            Text(viewModel.dateReturnPicked.formatted(date: .numeric, time: .shortened))
        }
        Rectangle()
            .frame(height: 1)
            .foregroundColor(.gray)
        
        if (viewModel.returnOptions.isEmpty){
            Spacer()
            ProgressView() // show loading symbol
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(1.5)
                .padding()
            Spacer()
            Spacer()
            Spacer()
            Spacer()
        }
        else{
            ScrollView {
                VStack {
                    ForEach (viewModel.outwardOptions.indices, id: \.self) { option in
                        NavigationLink (destination: OptionDetailsView(segments: viewModel.returnOptions[option], navigationPath: $navigationPath)){
                            OptionCard(option: viewModel.returnOptions[option], viewModel: viewModel)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
