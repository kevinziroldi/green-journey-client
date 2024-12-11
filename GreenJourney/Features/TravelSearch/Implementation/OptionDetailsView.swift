import SwiftUI

struct OptionDetailsView: View {
    var segments: [Segment]

    @EnvironmentObject var viewModel: TravelSearchViewModel
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        HeaderView(from: getOptionDeparture(segments), to: getOptionDestination(segments), date: segments.first?.dateTime)
        Rectangle()
            .frame(height: 1)
            .foregroundColor(.gray)
        ScrollView {
            HStack {
                VStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.black, lineWidth: 2)
                            .frame(maxWidth: .infinity, maxHeight: 100)
                            .shadow(radius: 10)
                        
                        VStack{
                            Text("Distance")
                                .font(.headline)
                                .padding(.bottom, 5)
                            HStack {
                                Image(systemName: "road.lanes")
                                    .font(.title)
                                Text(String(format: "%.1f", computeTotalDistance(segments)) + " Km")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                
                            }
                        }
                        .padding()
                    }
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.black, lineWidth: 2)
                            .frame(maxWidth: .infinity, maxHeight: 100)
                            .shadow(radius: 10)
                        
                        VStack{
                            Text("Price")
                                .font(.headline)
                                .padding(.bottom, 5)
                            HStack {
                                Image(systemName: "eurosign.bank.building")
                                    .font(.title)
                                    .foregroundStyle(.red)
                                Text(String(format: "%.1f", computeTotalPrice(segments)) + " €")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                            }
                        }
                        .padding()
                    }
                    
                }
                VStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.black, lineWidth: 2)
                            .frame(maxWidth: .infinity, maxHeight: 100)
                            .shadow(radius: 10)
                        
                        VStack {
                            Text("Duration")
                                .font(.headline)
                                .padding(.bottom, 5)
                            HStack{
                                Image(systemName: "clock")
                                    .font(.title)
                                    .foregroundStyle(.cyan)
                                Text(computeTotalDuration(segments))
                                    .font(.title3)
                                    .fontWeight(.semibold)
                            }
                        }
                        .padding()
                    }
                    
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.black, lineWidth: 2)
                            .frame(maxWidth: .infinity, maxHeight: 100)
                            .shadow(radius: 10)
                        
                        VStack{
                            Text("Price 0-emission")
                                .font(.headline)
                                .padding(.bottom, 5)
                            HStack {
                                Image(systemName: "eurosign.bank.building")
                                    .font(.title)
                                    .foregroundStyle(.green)
                                Text(String(format: "%.1f", computeTotalPrice(segments)) + " €")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                            }
                        }
                        .padding()
                    }
                }
            }
            .padding(EdgeInsets(top: 10, leading: 10, bottom: 20, trailing: 10))
            HStack (spacing: 50){
                VStack {
                    Text("Total CO2 emitted")
                        .font(.headline)
                        .padding(.bottom, 5)
                    Text(String(format: "%.1f", computeCo2Emitted(segments)) + " Kg")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                Image(systemName: "tree.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.red)
            }
            .padding(.bottom, 30)
            
            SegmentsView(segments: segments)
            Spacer()
        }
        if (!viewModel.oneWay) {
            if (viewModel.selectedOption.isEmpty) {
                Button ("proceed"){
                    viewModel.selectedOption.append(contentsOf: segments)
                    navigationPath.append(NavigationDestination.ReturnOptionsView)
                }
                .buttonStyle(.borderedProminent)

            }
            else {
                Button ("save travel") {
                    viewModel.selectedOption.append(contentsOf: segments)
                    viewModel.saveTravel()
                    viewModel.resetParameters()
                    navigationPath = NavigationPath()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        else {
            Button ("save travel") {
                viewModel.selectedOption.append(contentsOf: segments)
                viewModel.saveTravel()
                viewModel.resetParameters()
                navigationPath = NavigationPath()
            }
            .buttonStyle(.borderedProminent)

        }
        
    }
    
    
    func getOptionDeparture (_ travelOption: [Segment]) -> String {
        if let firstSegment = travelOption.first {
            return firstSegment.departureCity
        }
        else {
            return ""
        }
    }
    
    func getOptionDestination (_ travelOption: [Segment]) -> String {
        if let lastSegment = travelOption.last {
            return lastSegment.destinationCity
        }
        else {
            return ""
        }
    }
    func computeCo2Emitted(_ travelOption: [Segment]) -> Float64 {
        var co2Emitted: Float64 = 0.0
        for segment in travelOption {
            co2Emitted += segment.co2Emitted
        }
        return co2Emitted
    }
    
    func computeTotalPrice (_ travelOption: [Segment]) -> Float64 {
        var price: Float64 = 0.0
        for segment in travelOption {
            price += segment.price
        }
        return price
    }
    
    func computeTotalDistance(_ travelOption: [Segment]) -> Float64 {
        var distance: Float64 = 0.0
        for segment in travelOption {
            distance += segment.distance
        }
        return distance
    }
    func computeTotalDuration (_ travelOption: [Segment]) -> String {
        var hours: Int = 0
        var minutes: Int = 0
        for segment in travelOption {
            hours += durationToHoursAndMinutes(duration: segment.duration).hours
            minutes += durationToHoursAndMinutes(duration: segment.duration).minutes
        }
        while (minutes >= 60) {
            hours += 1
            minutes -= 60
        }
        return "\(hours) h, \(minutes) min"
    }
    
    func durationToHoursAndMinutes(duration: Int) -> (hours: Int, minutes: Int) {
        let hours = duration / (3600 * 1000000000)       // 1 hour = 3600 secsecondsondi
        let remainingSeconds = (duration / 1000000000) % (3600)
        let minutes = remainingSeconds / 60  // 1 minute = 60 seconds
        
        return (hours, minutes)
    }
}
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
                Text(segment.dateTime.addingTimeInterval(TimeInterval(segment.duration/1000000000)).formatted(date: .numeric, time: .shortened))
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
                    .frame(width: .infinity, height: 75, alignment: .top)
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
        }
    }
}
