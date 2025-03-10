import SwiftUI
import Charts

struct GeneralDetailsView: View {
    @ObservedObject var viewModel: DashboardViewModel
    var body: some View {
        ScrollView {
            VStack {
                HorizontalBarChart(keys: viewModel.distancePerTransport.keys.sorted(), data: viewModel.distancePerTransport.keys.sorted().map{viewModel.distancePerTransport[$0]!}, title: "Distance per vehicle", color: .pink, measureUnit: "Km")
                    .padding()
                    .frame(height: 250)
                
                BarChartView(title: "Distance traveled (Km)", value: "", data: viewModel.distances.keys.sorted().map{viewModel.distances[$0]!}, labels: viewModel.keysToString(keys: viewModel.distances.keys.sorted()), color: .indigo.opacity(0.8))
                    .padding()
                    .overlay(Color.clear.accessibilityIdentifier("distanceTraveled"))
                
                PieChartView(keys: viewModel.travelsPerTransport.keys.sorted(), data: viewModel.travelsPerTransport.keys.sorted().map{viewModel.travelsPerTransport[$0]!}, title: "Most chosen Vehicle", color: .orange, icon: viewModel.mostChosenVehicle)
                    .padding()
                
                BarChartView(title: "Trips completed", value: "\(viewModel.totalTripsMade)", data: viewModel.tripsMade.keys.sorted().map{viewModel.tripsMade[$0]!}, labels: viewModel.keysToString(keys: viewModel.tripsMade.keys.sorted()) , color: .pink.opacity(0.8))
                    .padding()
                    .overlay(Color.clear.accessibilityIdentifier("tripsCompleted"))

                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color(uiColor: .systemBackground))
                        .shadow(color: .indigo.opacity(0.3), radius: 5, x: 0, y: 3)
                    VStack (spacing:0){
                        Text("Recap")
                            .font(.title)
                            .foregroundStyle(.indigo.opacity(0.8))
                            .padding()
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        InfoRowView(title: "Distance made", value: String(format: "%.0f", viewModel.totalDistance) + " Km", icon: "road.lanes", color: .indigo, imageValue: false, imageValueString: nil)
                        InfoRowView(title: "Travel time", value: viewModel.totalDurationString, icon: "clock", color: .indigo, imageValue: false, imageValueString: nil)
                    }
                    .padding(.bottom, 7)
                }
                .padding()
            }
            .padding(.horizontal)
        }
    }
}

