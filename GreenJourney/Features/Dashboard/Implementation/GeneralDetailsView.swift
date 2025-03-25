import SwiftUI
import Charts

struct GeneralDetailsView: View {
    @ObservedObject var viewModel: DashboardViewModel
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        ScrollView {
            VStack {
                if horizontalSizeClass == .compact {
                    // iOS
                    
                    VStack {
                        HorizontalBarChart(keys: viewModel.distancePerTransport.keys.sorted(), data: viewModel.distancePerTransport.keys.sorted().map{viewModel.distancePerTransport[$0]!}, title: "Distance per vehicle", color: AppColors.blue, measureUnit: "Km")
                            .padding()
                            .frame(height: 250)
                            .overlay(Color.clear.accessibilityIdentifier("distancePerVehicle"))
                        
                        BarChartView(title: "Distance traveled (Km)", value: "", data: viewModel.distances.keys.sorted().map{viewModel.distances[$0]!}, labels: viewModel.keysToString(keys: viewModel.distances.keys.sorted()), color: AppColors.blue)
                            .padding()
                            .overlay(Color.clear.accessibilityIdentifier("distancePerYear"))
                        
                        PieChartView(keys: viewModel.travelsPerTransport.keys.sorted(), data: viewModel.travelsPerTransport.keys.sorted().map{viewModel.travelsPerTransport[$0]!}, title: "Most chosen Vehicle", color: AppColors.blue, icon: viewModel.mostChosenVehicle)
                            .padding()
                            .overlay(Color.clear.accessibilityIdentifier("mostChosenVehicle"))
                        
                        BarChartView(title: "Trips completed", value: "\(viewModel.totalTripsMade)", data: viewModel.tripsMade.keys.sorted().map{viewModel.tripsMade[$0]!}, labels: viewModel.keysToString(keys: viewModel.tripsMade.keys.sorted()) , color: AppColors.blue)
                            .padding()
                            .overlay(Color.clear.accessibilityIdentifier("tripsCompleted"))
                        
                        DistanceTimeRecapView(viewModel: viewModel)
                    }
                    .frame(maxWidth: 800)
                } else {
                    // iPadOS
                    
                    VStack {
                        HStack {
                            BarChartView(title: "Distance traveled (Km)", value: "", data: viewModel.distances.keys.sorted().map{viewModel.distances[$0]!}, labels: viewModel.keysToString(keys: viewModel.distances.keys.sorted()), color: AppColors.blue)
                                .padding()
                                .overlay(Color.clear.accessibilityIdentifier("distancePerYear"))
                            
                            BarChartView(title: "Trips completed", value: "\(viewModel.totalTripsMade)", data: viewModel.tripsMade.keys.sorted().map{viewModel.tripsMade[$0]!}, labels: viewModel.keysToString(keys: viewModel.tripsMade.keys.sorted()) , color: AppColors.blue)
                                .padding()
                                .overlay(Color.clear.accessibilityIdentifier("tripsCompleted"))
                        }
                        
                        HorizontalBarChart(keys: viewModel.distancePerTransport.keys.sorted(), data: viewModel.distancePerTransport.keys.sorted().map{viewModel.distancePerTransport[$0]!}, title: "Distance per vehicle", color: AppColors.blue, measureUnit: "Km")
                            .padding()
                            .frame(height: 250)
                            .overlay(Color.clear.accessibilityIdentifier("distancePerVehicle"))
                        
                        HStack(alignment: .top) {
                            PieChartView(keys: viewModel.travelsPerTransport.keys.sorted(), data: viewModel.travelsPerTransport.keys.sorted().map{viewModel.travelsPerTransport[$0]!}, title: "Most chosen Vehicle", color: AppColors.blue, icon: viewModel.mostChosenVehicle)
                                .padding()
                                .overlay(Color.clear.accessibilityIdentifier("mostChosenVehicle"))
                            
                            DistanceTimeRecapView(viewModel: viewModel)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .frame(maxWidth: 800)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
        }
        .background(colorScheme == .dark ? AppColors.backColorDark : AppColors.backColorLight)
    }
}

private struct DistanceTimeRecapView: View {
    @ObservedObject var viewModel: DashboardViewModel
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(uiColor: .systemBackground))
                .shadow(color: AppColors.blue.opacity(0.3), radius: 5, x: 0, y: 3)
            VStack (spacing:0){
                Text("Recap")
                    .font(.title)
                    .foregroundStyle(AppColors.blue)
                    .padding()
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                InfoRowView(title: "Distance", value: String(format: "%.0f", viewModel.totalDistance) + " Km", icon: "road.lanes", isSystemIcon: true, color: AppColors.blue, imageValue: false, imageValueString: nil)
                InfoRowView(title: "Travel time", value: viewModel.totalDurationString, icon: "clock",  isSystemIcon: true, color: AppColors.blue, imageValue: false, imageValueString: nil)
            }
            .padding(.bottom, 7)
        }
        .padding()
        .overlay(Color.clear.accessibilityIdentifier("distanceTimeRecap"))
    }
}
