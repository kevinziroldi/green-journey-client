import SwiftData
import SwiftUI

struct MyTravelsView: View {
    @EnvironmentObject var viewModel: MyTravelsViewModel
    @State private var selectedSortOption: SortOption = .departureDate
    @State private var showSortOptions = false
    
    @State private var showAlert: Bool = false
    @State private var showConfirm: Bool = false
    
    @Binding var navigationPath: NavigationPath
    @Environment(\.modelContext) private var modelContext
        
    init(modelContext: ModelContext, navigationPath: Binding<NavigationPath>) {
        _navigationPath = navigationPath
    }
    var body: some View {
        VStack {
            HStack {
                Text("My Travels")
                    .font(.title)
                    .padding()
                Spacer()
                
                NavigationLink(destination: UserPreferencesView(navigationPath: $navigationPath)) {
                    Image(systemName: "person")
                        .font(.title)
                }
            }
            .padding(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
            
            Picker("", selection: $viewModel.showCompleted) {
                Text("Completed").tag(true)
                Text("Scheduled").tag(false)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            Button(action: {
                showSortOptions.toggle()
            }) {
                Text("Order by")
            }
            .padding()
            .actionSheet(isPresented: $showSortOptions) {
                ActionSheet(title: Text("Order by"), buttons: [
                    .default(Text("Departure date")) {viewModel.sortOption = .departureDate},
                    .default(Text("CO2 emitted")) {viewModel.sortOption = .co2Emitted},
                    .default(Text("CO2 compensation rate")) {viewModel.sortOption = .co2CompensationRate},
                    .default(Text("Price")) {viewModel.sortOption = .price},
                    .cancel()
                ])
            }
            ScrollView {
                VStack{
                    ForEach(viewModel.filteredTravelDetailsList, id: \.id) { travelDetails in
                        HStack (spacing: 10) {
                            NavigationLink(destination: TravelDetailsView(travelDetails: travelDetails, navigationPath: $navigationPath)) {
                                TravelCard(travelDetails: travelDetails)
                            }
                            if viewModel.showCompleted && !travelDetails.travel.confirmed {
                                VStack {
                                    
                                    Button(action: {
                                        showConfirm = true
                                    }) {
                                        Image(systemName: "checkmark.circle")
                                            .font(.largeTitle)
                                            .scaleEffect(1.2)
                                            .fontWeight(.light)
                                            .foregroundStyle(.green)
                                    }
                                    .padding(.vertical, 5)
                                    .alert(isPresented: $showConfirm) {
                                        Alert(
                                            title: Text("Have you done this travel?"),
                                            primaryButton: .cancel(Text("Cancel")) {},
                                            secondaryButton: .default(Text("Confirm")) {
                                                //confirm travel
                                                viewModel.confirmTravel(travel: travelDetails.travel)
                                            }
                                        )
                                    }
                                    
                                    Button(action: {
                                        showAlert = true
                                    }) {
                                        Image(systemName: "trash.circle")
                                            .font(.largeTitle)
                                            .scaleEffect(1.2)
                                            .fontWeight(.light)
                                            .foregroundStyle(.red)
                                    }
                                    .padding(.vertical, 5)
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
                            }
                        }
                        .padding(EdgeInsets(top: 5, leading: 15, bottom: 5, trailing: 15))
                    }
                }
            }
        }
        .onAppear {
            viewModel.getUserTravels()
        }
    }
}

struct TravelCard: View {
    let travelDetails: TravelDetails
    
    var co2Emitted: Float64 {
        var co2Emitted = 0.0
        for segment in travelDetails.segments {
            co2Emitted += segment.co2Emitted
        }
        return co2Emitted
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .stroke()
            
            VStack {
                HStack{
                    ZStack{
                        Circle()
                            .stroke(lineWidth: 2)
                            .frame(width: 45, height: 45)
                        Image(systemName: findVehicle(travelDetails.segments))
                            .font(.title2)
                        
                    }
                    .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0))
                    Spacer()
                    VStack {
                        HStack (spacing: 10){
                            Text(getOptionDeparture(travelDetails.segments))
                                .font(.headline)
                            Text("-")
                                .font(.headline)
                            Text(getOptionDestination(travelDetails.segments))
                                .font(.headline)
                        }
                        HStack{
                            Text(travelDetails.segments.first?.dateTime.formatted(date: .numeric, time: .omitted) ?? "")
                                .font(.subheadline)
                                .fontWeight(.light)
                            Text("-")
                                .font(.subheadline)
                            let arrivalDate = travelDetails.segments.last?.dateTime.addingTimeInterval(TimeInterval(travelDetails.segments.last?.duration ?? 0) / 1000000000)
                            Text(arrivalDate?.formatted(date: .numeric, time: .omitted) ?? "")
                                .font(.subheadline)
                                .fontWeight(.light)
                        }
                    }
                    Spacer()
                    Image(systemName: "chevron.forward")
                        .font(.title2)
                        .foregroundStyle(.blue)
                    
                }
                GeometryReader { geometry in
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: 0))
                        path.addLine(to: CGPoint(x: geometry.size.width, y: 0))
                    }
                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [20, 10]))
                    .foregroundStyle(.black)
                }
                .padding(EdgeInsets(top: 7, leading: 5, bottom: 0, trailing: 0))
                
                HStack {
                    Image(systemName: "carbon.dioxide.cloud")
                        .scaleEffect(1.5)
                        .padding(.bottom, 5)
                        .padding(.trailing, 10)
                    Text("Compensation:" )
                    Text(String(format: "%.2f", travelDetails.travel.CO2Compensated) + " / " + String(format: "%.2f", co2Emitted) + " Kg")
                }
            }
            .padding()
        }
        .foregroundStyle(.black)
        
    }
    
    func getOptionDeparture (_ travelOption: [Segment]) -> String {
        if let firstSegment = travelOption.first {
            return firstSegment.departureCity
        }
        else {
            return ""
        }
    }
    
    func findVehicle(_ option: [Segment]) -> String {
        var vehicle: String
        switch option.first?.vehicle {
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
        default:
            vehicle = ""
        }
        return vehicle
    }
    
    func getOptionDestination (_ travelOption: [Segment]) -> String {
        if let lastSegment = travelOption.last {
            return lastSegment.destinationCity
        }
        else {
            return ""
        }
    }
}




