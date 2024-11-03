import SwiftUI

struct TravelsView: View {
    @ObservedObject var viewModel = TravelsViewModel()
    @State private var selectedSortOption: SortOption = .departureDate
    @State private var showSortOptions = false
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Text("My Travels")
                        .font(.title)
                        .padding()
                    Spacer()
                    
                    
                    NavigationLink(destination: UserPreferencesView()) {
                        Image(systemName: "person")
                            .font(.title)
                    }
                    .padding()
                }
                
                Picker("", selection: $viewModel.showCompleted) {
                    Text("Completed").tag(true)
                    Text("Scheduled").tag(false)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                /*
                Button(action: {
                    showSortOptions.toggle()
                }) {
                    Text("Order by")
                }
                .padding()
                .actionSheet(isPresented: $showSortOptions) {
                    ActionSheet(title: Text("Order by"), buttons: [
                        .default(Text("Departure Date")) { viewModel.sortTravels(by: .departureDate) },
                        .default(Text("Price")) { viewModel.sortTravels(by: .price) },
                        .cancel()
                    ])
                }
                */
                
                List(viewModel.travelDetails) { travelDetails in
                    TravelRow(travelDetails: travelDetails)
                }
            }
            .onAppear {
                viewModel.fetchTravels(for: 2)  // TODO scegliere dinamicamente!!!
            }
        }
    }
}

struct TravelRow: View {
    let travelDetails: TravelDetails
    var departure: String {
        travelDetails.segments.first?.departure ?? "Unknown"
    }
    var destination: String {
        travelDetails.segments.last?.destination ?? "Unknown"
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

enum SortOption {
    case departureDate
    case price
}

let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    return formatter
}()


#Preview {
    TravelsView()
}
