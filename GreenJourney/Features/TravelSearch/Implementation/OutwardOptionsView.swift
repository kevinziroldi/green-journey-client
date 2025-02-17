import SwiftUI

struct OutwardOptionsView: View {
    @ObservedObject var viewModel: TravelSearchViewModel
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        VStack (spacing: 0){
            HStack {
                Text(viewModel.departure.cityName)
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
                Text(viewModel.arrival.cityName)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding()
            }
            Text(viewModel.datePicked.formatted(date: .numeric, time: .shortened))
        }
        Rectangle()
            .frame(height: 1)
            .foregroundColor(.gray)
        
        if (viewModel.outwardOptions.isEmpty){
            Spacer()
            CircularProgressView()
            Spacer()
            Spacer()
            Spacer()
            Spacer()
        }
        else{
            ScrollView {
                VStack {
                    ForEach (viewModel.outwardOptions.indices, id: \.self) { option in
                        NavigationLink (destination: OptionDetailsView(segments: viewModel.outwardOptions[option], viewModel: viewModel, navigationPath: $navigationPath)){
                            OptionCard(option: viewModel.outwardOptions[option], viewModel: viewModel)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}



struct OptionCard: View {
    var option: [Segment]
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var viewModel: TravelSearchViewModel
    
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 20)
                .stroke(colorScheme == .dark ? Color.white.opacity(0.6) : Color.black.opacity(0.6), lineWidth: 2)
                .fill(colorScheme == .dark ? Color(red: 48/255, green: 48/255, blue: 48/255) : Color.white)
            VStack{
                HStack{
                    Image(systemName: viewModel.findVehicle(option))
                        .font(.title2)
                        .padding(EdgeInsets(top: -20, leading: 10, bottom: 0, trailing: 0))
                    Spacer()
                    VStack{
                        
                        Text(option.first?.dateTime.formatted(date: .numeric, time: .shortened) ?? "")
                            .font(.subheadline)
                            .fontWeight(.light)
                        Text(viewModel.getOptionDeparture(option))
                            .font(.title3)
                        ZStack {
                            if (option.count > 1){
                                if (option.count == 2){
                                    Text("\(option.count) change")
                                        .foregroundStyle(.blue)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                }
                                else {
                                    Text("\(option.count - 1) changes")
                                        .foregroundStyle(.blue)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                }
                             }
                        }
                        Text(viewModel.getOptionDestination(option))
                            .font(.title3)
                        
                        let arrivalDate = option.last?.getArrivalDateTime()
                        Text(arrivalDate?.formatted(date: .numeric, time: .shortened) ?? "")
                            .font(.subheadline)
                            .fontWeight(.light)
                        
                    }
                    Spacer()
                    VStack {
                        Image(systemName: "carbon.dioxide.cloud")
                            .font(.title)
                            .scaleEffect(1.5)
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 5, trailing: 0))
                        Text(String(format: "%.2f", viewModel.computeCo2Emitted(option)) + " Kg")
                    }
                    Spacer()
                    Image(systemName: "chevron.forward")
                        .font(.title2)
                        .foregroundStyle(.blue)
                }
                
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.gray)
                HStack{
                    Spacer()
                    Image(systemName: "clock")
                        .font(.title3)
                        .padding(EdgeInsets(top: 7, leading: 0, bottom: 5, trailing: 0))
                    Text(viewModel.computeTotalDuration(option))
                    Spacer()
                    Text("price: " + String(format: "%.2f", viewModel.computeTotalPrice(option)) + "€")
                        .foregroundStyle(.green)
                    Spacer()
                }
            }
            .padding()
        }
        .padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10))
        
    }
}

 
struct CircularProgressView: View {
    @State private var rotation: Double = 0

    var body: some View {
        ZStack {
            // background circle
            Circle()
                .stroke(lineWidth: 8)
                .opacity(0.3)
                .foregroundColor(Color.gray)
            
            // rotating part
            Circle()
                .trim(from: 0, to: 0.3)
                .stroke(style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .foregroundStyle(LinearGradient(colors: [Color.blue, Color.green], startPoint: .leading, endPoint: .trailing))
                .rotationEffect(.degrees(rotation))
                .onAppear {
                    withAnimation(Animation.linear(duration: 3).repeatForever(autoreverses: false)) {
                        rotation = 360
                    }
                }
            Image("icon_no_background")
                .resizable()
                .frame(width: 60, height: 60)
        }
        .frame(width: 90, height: 90)
    }
}
