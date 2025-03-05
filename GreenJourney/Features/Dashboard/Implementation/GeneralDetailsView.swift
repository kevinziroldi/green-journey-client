import SwiftUI
import Charts

struct GeneralDetailsView: View {
    @ObservedObject var viewModel: DashboardViewModel
    var body: some View {
        ScrollView {
            VStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color(uiColor: .systemBackground))
                        .shadow(color: .indigo.opacity(0.3), radius: 5, x: 0, y: 3)
                    VStack (spacing:0){
                        Text("Recap")
                            .font(.title)
                            .foregroundStyle(.indigo.opacity(0.8))
                            .padding(EdgeInsets(top: 15, leading: 15, bottom: 0, trailing: 0))
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        InfoRow(title: "Distance made", value: String(format: "%.0f", viewModel.totalDistance) + " Km", icon: "road.lanes", color: .indigo, imageValue: false, imageValueString: nil)
                        
                        InfoRow(title: "Travel time", value: viewModel.totalDurationString, icon: "clock", color: .blue, imageValue: false, imageValueString: nil)
                        
                        InfoRow(title: "Most chosen vehicle", value: "", icon: "figure.wave", color: .indigo, imageValue: true, imageValueString: viewModel.mostChosenVehicle)
                        
                        
                    }
                }
                .padding()
                
                BarChartView(title: "Trips completed", value: "\(viewModel.totalTripsMade)", data: viewModel.tripsMade.keys.sorted().map{viewModel.tripsMade[$0]!}, labels: viewModel.keysToString(keys: viewModel.tripsMade.keys.sorted()) , color: .pink.opacity(0.8))
                    .padding()
                    .overlay(Color.clear.accessibilityIdentifier("tripsCompleted"))
                
                BarChartView(title: "Distance traveled (Km)", value: "", data: viewModel.distances.keys.sorted().map{viewModel.distances[$0]!}, labels: viewModel.keysToString(keys: viewModel.distances.keys.sorted()), color: .indigo.opacity(0.8))
                    .padding()
                    .overlay(Color.clear.accessibilityIdentifier("distanceTraveled"))
                
                PieChartView(keys: viewModel.distancePerTransport.keys.sorted(), data: viewModel.travelsPerTransport.keys.sorted().map{viewModel.travelsPerTransport[$0]!}, title: "Most chosen Vehicle", color: .blue, icon: viewModel.mostChosenVehicle)
                    .padding()
            }
        }
    }
}


struct PieChartView: View {
    var keys: [String]
    var data: [Int]
    var title: String
    let color: Color
    let icon: String
    var body: some View {
        VStack {
            HStack {
                Text(title)
                    .font(.title)
                    .foregroundStyle(color.opacity(0.8))
                    .fontWeight(.semibold)
                    .padding()
                Spacer()
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2).gradient)
                        .frame(width: 50, height: 50)
                    Image(systemName: icon)
                        .foregroundStyle(color)
                        .font(.title)
                }
                Spacer()
                Spacer()
            }
            Chart {
                ForEach(data.indices, id: \..self) { index in
                    SectorMark(angle: .value("Distance", data[index]), angularInset: 2)
                        .foregroundStyle(by: .value("Vehicle", keys[index]))
                        .cornerRadius(5)
                        .annotation(position: .overlay) {
                            if data[index] != 0 {
                                Text("\(data[index])")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                            }
                        }
                }
                
            }
            .padding()
            .padding(.bottom)
        }
        .frame(height: 350)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}
