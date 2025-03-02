import SwiftData
import SwiftUI

struct MyTravelsView: View {
    @StateObject var viewModel: MyTravelsViewModel
    @Environment(\.modelContext) private var modelContext
    private var serverService: ServerServiceProtocol
    private var firebaseAuthService: FirebaseAuthServiceProtocol
    
    @State private var selectedSortOption: SortOption = .departureDate
    @State private var showSortOptions = false
    
    @State private var showAlert: Bool = false
    @State private var showConfirm: Bool = false
    
    @Binding var navigationPath: NavigationPath
    @Environment(\.colorScheme) var colorScheme: ColorScheme
        
    init(modelContext: ModelContext,navigationPath: Binding<NavigationPath>, serverService: ServerServiceProtocol, firebaseAuthService: FirebaseAuthServiceProtocol) {
        _viewModel = StateObject(wrappedValue: MyTravelsViewModel(modelContext: modelContext, serverService: serverService))
        _navigationPath = navigationPath
        self.serverService = serverService
        self.firebaseAuthService = firebaseAuthService
    }
    var body: some View {
        VStack {
            HStack {
                Text("My travels")
                    .font(.system(size: 32).bold())
                    .padding()
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityIdentifier("myTravelsTitle")
                
                Spacer()
                
                NavigationLink(destination: UserPreferencesView(modelContext: modelContext, navigationPath: $navigationPath, serverService: serverService, firebaseAuthService: firebaseAuthService)) {
                    Image(systemName: "person")
                        .font(.title)
                        .foregroundStyle(AppColors.mainGreen)
                }
                .accessibilityIdentifier("userPreferencesButton")
            }
            .padding(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
            
            Picker("", selection: $viewModel.showCompleted) {
                Text("Completed").tag(true)
                Text("Scheduled").tag(false)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            .accessibilityIdentifier("travelCompletedControl")
            
            HStack {
                Spacer()
                Button(action: {
                    showSortOptions.toggle()
                }) {
                    Text("Order by")
                }
                .padding(.trailing, 20)
                .actionSheet(isPresented: $showSortOptions) {
                    ActionSheet(title: Text("Sort by"), buttons: [
                        .default(Text("Departure date")) {viewModel.sortOption = .departureDate},
                        .default(Text("CO2 emitted")) {viewModel.sortOption = .co2Emitted},
                        .default(Text("CO2 compensation rate")) {viewModel.sortOption = .co2CompensationRate},
                        .default(Text("Price")) {viewModel.sortOption = .price},
                        .cancel()
                    ])
                }
                .accessibilityIdentifier("sortByButton")
            }
            
            ScrollView {
                if viewModel.filteredTravelDetailsList.count == 0 {
                    VStack {
                        if colorScheme == .dark {
                            Image("noTravelsDark")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 300, height: 300)
                        }
                        else {
                            Image("noTravelsLight")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 300, height: 300)
                        }
                        Text("You have no trips in this section yet")
                            .font(.headline)
                            .fontWeight(.light)
                    }
                    .accessibilityIdentifier("noTravelsAlert")
                }
                else {
                    VStack{
                        ForEach(viewModel.filteredTravelDetailsList, id: \.id) { travelDetails in
                            HStack (spacing: 10) {
                                Button(action: {
                                    viewModel.selectedTravel = travelDetails
                                    // selectedTravel is set synchronously
                                    navigationPath.append(NavigationDestination.TravelDetailsView(viewModel))
                                }) {
                                    TravelCard(travelDetails: travelDetails)
                                }
                                .accessibilityIdentifier("travelCardButton_\(travelDetails.travel.travelID ?? 1)")
                                
                                if viewModel.showCompleted && !travelDetails.travel.confirmed {
                                    VStack {
                                        
                                        Button(action: {
                                            showConfirm = true
                                            viewModel.selectedTravel = travelDetails
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
                                                    Task {
                                                        await viewModel.confirmTravel()
                                                    }
                                                }
                                            )
                                        }
                                        .accessibilityIdentifier("confirmTravelButton_\(travelDetails.travel.travelID ?? 1)")
                                        
                                        Button(action: {
                                            showAlert = true
                                            viewModel.selectedTravel = travelDetails
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
                                                    Task {
                                                        await viewModel.deleteTravel()
                                                    }
                                                }
                                            )
                                        }
                                        .accessibilityIdentifier("deleteTravelButton_\(travelDetails.travel.travelID ?? 1)")
                                    }
                                }
                            }
                            .padding(EdgeInsets(top: 5, leading: 15, bottom: 5, trailing: 15))
                        }
                    }
                }
            }
        }
        .onAppear {
            viewModel.showRequestedTravels()
            if viewModel.filteredTravelDetailsList.isEmpty {
                // retry
                viewModel.showRequestedTravels()
            }
            // else empty page
        }
    }
}

struct TravelCard: View {
    let travelDetails: TravelDetails
    @EnvironmentObject var viewModel: MyTravelsViewModel
    @Environment(\.colorScheme) var colorScheme: ColorScheme

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .stroke(computeTravelColor(travel: travelDetails), lineWidth: 5)
                .fill(computeTravelBackColor(travel: travelDetails))
            
            VStack {
                HStack{
                    VStack {
                        ZStack{
                            Circle()
                                .stroke(lineWidth: 2)
                                .frame(width: 45, height: 45)
                            Image(systemName: travelDetails.findVehicle(outwardDirection: true))
                                .font(.title2)
                            
                        }
                        if !travelDetails.isOneway() {
                            ZStack{
                                Circle()
                                    .stroke(lineWidth: 2)
                                    .frame(width: 45, height: 45)
                                Image(systemName: travelDetails.findVehicle(outwardDirection: false))
                                    .font(.title2)
                                
                            }
                        }
                    }
                    .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0))
                    Spacer()
                    VStack {
                        HStack (spacing: 10){
                            Text(travelDetails.getDepartureSegment()?.departureCity ?? "")
                                .font(.headline)
                            Text("-")
                                .font(.headline)
                            Text(travelDetails.getDestinationSegment()?.destinationCity ?? "")
                                .font(.headline)
                        }
                        HStack{
                            Text(travelDetails.getOutwardSegments().first?.dateTime.formatted(date: .numeric, time: .omitted) ?? "")
                                .font(.subheadline)
                                .fontWeight(.light)
                            Text("-")
                                .font(.subheadline)
                            let arrivalDate = travelDetails.getOutwardSegments().last?.getArrivalDateTime()
                            Text(arrivalDate?.formatted(date: .numeric, time: .omitted) ?? "")
                                .font(.subheadline)
                                .fontWeight(.light)
                        }
                        if !travelDetails.isOneway() {
                            HStack (spacing: 10){
                                Text(travelDetails.getDestinationSegment()?.destinationCity ?? "")
                                    .font(.headline)
                                Text("-")
                                    .font(.headline)
                                Text(travelDetails.getDepartureSegment()?.departureCity ?? "")
                                    .font(.headline)
                            }
                            HStack{
                                Text(travelDetails.getReturnSegments().first?.dateTime.formatted(date: .numeric, time: .omitted) ?? "")
                                    .font(.subheadline)
                                    .fontWeight(.light)
                                Text("-")
                                    .font(.subheadline)
                                let arrivalDate = travelDetails.getReturnSegments().last?.getArrivalDateTime()
                                Text(arrivalDate?.formatted(date: .numeric, time: .omitted) ?? "")
                                    .font(.subheadline)
                                    .fontWeight(.light)
                            }
                        }
                    }
                    Spacer()
                    VStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .stroke()
                            if travelDetails.isOneway() {
                                Text("One way")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .padding(5)
                            }
                            else {
                                Text("Round trip")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .padding(5)
                            }
                        }
                        .fixedSize()
                        Spacer()
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
                    .foregroundStyle(colorScheme == .dark ? Color.white : Color.black)
                }
                .padding(EdgeInsets(top: 7, leading: 5, bottom: 0, trailing: 0))
                
                HStack {
                    Image(systemName: "carbon.dioxide.cloud")
                        .scaleEffect(1.5)
                        .padding(.bottom, 5)
                        .padding(.trailing, 10)
                    Text("Compensation:" )
                    Text(String(format: "%.2f", travelDetails.travel.CO2Compensated) + " / " + String(format: "%.2f", travelDetails.computeCo2Emitted()) + " Kg")
                }
            }
            .padding()
            .foregroundStyle(colorScheme == .dark ? Color.white : Color.black)
        }
    }
    
    func computeTravelColor(travel : TravelDetails) -> LinearGradient {
        let co2Emitted = travel.computeCo2Emitted()
        let distance = travel.computeTotalDistance()
        if co2Emitted == 0.0 {
            return LinearGradient(colors: [.green.opacity(0.7), .blue.opacity(0.7)], startPoint: .bottomLeading, endPoint: .topTrailing)
        }
        if travel.travel.CO2Compensated >= travel.computeCo2Emitted() {
            return LinearGradient(colors: [.green.opacity(0.7), .blue.opacity(0.7)], startPoint: .bottomLeading, endPoint: .topTrailing)
        }
        if distance/co2Emitted > 30 {
            return AppColors.ecoGreenTravel
        }
        if distance/co2Emitted > 20 {
            return AppColors.ecoYellowTravel
        }
        return AppColors.ecoRedTravel
    }
    
    func computeTravelBackColor(travel: TravelDetails) -> LinearGradient{
        if travel.travel.CO2Compensated >= travel.computeCo2Emitted() {
            return LinearGradient(colors: [.green.opacity(0.3), .blue.opacity(0.3)], startPoint: .bottomLeading, endPoint: .topTrailing)
        }
        else {
            return LinearGradient(colors: [.clear], startPoint: .bottomLeading, endPoint: .topTrailing)
        }
    }
}
