import SwiftData
import SwiftUI

struct TravelsView: View {
    @StateObject var viewModel: TravelsViewModel
    @State private var selectedSortOption: SortOption = .departureDate
    @State private var showSortOptions = false
    @Binding var navigationPath: NavigationPath
    @Environment(\.modelContext) private var modelContext
    
    @Query var users: [User]
    
    init(modelContext: ModelContext, navigationPath: Binding<NavigationPath>) {
        _viewModel = StateObject(wrappedValue: TravelsViewModel(modelContext: modelContext))
        _navigationPath = navigationPath
    }
    
    var body: some View {
        if users.first != nil {
            VStack {
                HStack {
                    Text("My Travels")
                        .font(.title)
                        .padding()
                    Spacer()
                    
                    Button(action: {
                        navigationPath.append("UserPreferencesView")
                    }) {
                        Image(systemName: "person")
                            .font(.title)
                    }
                }
                
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
                
                List(viewModel.filteredTravelDetailsList) { travelDetails in
                    TravelRow(travelDetails: travelDetails)
                }
            }
            .onAppear {
                viewModel.getUserTravels()
            }
        }else {
            LoginView(modelContext: modelContext)
                .transition(.opacity.animation(.easeInOut(duration: 0.2)))
        }
    }
}

struct TravelRow: View {
    let travelDetails: TravelDetails
    var departure: String {
        travelDetails.segments.first?.departureCity ?? "Unknown"
    }
    var destination: String {
        travelDetails.segments.last?.destinationCity ?? "Unknown"
    }
    var departureDate: String {
        dateFormatter.string(for: travelDetails.segments.first?.date) ?? "Unknown"
    }
    var destinationDate: String {
        let durationSeconds = Double((travelDetails.segments.last?.duration ?? 0) / 1_000_000_000)
        let departureDateLastSegment = travelDetails.segments.last?.date
        let arrivalDate = departureDateLastSegment?.addingTimeInterval(durationSeconds)
        return dateFormatter.string(for: arrivalDate) ?? "Unkwnown"
    }
    var co2Compensated: String {
        String(travelDetails.travel.CO2Compensated)
    }
    var co2Emitted: String {
        var co2Emitted = 0.0
        for segment in travelDetails.segments {
            co2Emitted += segment.co2Emitted
        }
        return String(co2Emitted)
    }
    
    var body: some View {
        VStack {
            Text("\(departure) - \(destination)")
            .font(.headline)
            
            Text("\(departureDate) - \(destinationDate)")
            
            Text("\(co2Compensated)/\(co2Emitted)")
        }
        .padding()
    }
}

let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    return formatter
}()

