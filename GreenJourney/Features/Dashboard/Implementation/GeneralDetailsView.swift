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
                        HorizontalBarChart(data: viewModel.distancePerTransport, title: "Distance per vehicle", measurementUnit: "Km", color: AppColors.blue, sortByKey: true)
                            .padding()
                            .frame(height: 250)
                            .overlay(Color.clear.accessibilityIdentifier("distancePerVehicle"))
                        
                        BarChartView(data: viewModel.distances, title: "Distance traveled (Km)", value: "", color: AppColors.blue)
                            .padding()
                            .overlay(Color.clear.accessibilityIdentifier("distancePerYear"))
                        
                        
                        PieChartView(data: viewModel.travelsPerTransport, title: "Most chosen Vehicle", color: AppColors.blue, icon: viewModel.mostChosenVehicle, colors: [AppColors.blue, AppColors.orange, AppColors.green, AppColors.red, AppColors.purple])
                            .padding()
                            .overlay(Color.clear.accessibilityIdentifier("mostChosenVehicle"))
                        
                        BarChartView(data: viewModel.tripsMade, title: "Trips completed", value: "\(viewModel.totalTripsMade)", color: AppColors.blue)
                            .padding()
                            .overlay(Color.clear.accessibilityIdentifier("tripsCompleted"))
                        
                        DistanceTimeRecapView(viewModel: viewModel)
                    }
                    .frame(maxWidth: 800)
                } else {
                    // iPadOS
                    
                    VStack {
                        HStack {
                            BarChartView(data: viewModel.distances, title: "Distance traveled (Km)", value: "", color: AppColors.blue)
                                .padding()
                                .overlay(Color.clear.accessibilityIdentifier("distancePerYear"))
                            
                            BarChartView(data: viewModel.tripsMade, title: "Trips completed", value: "\(viewModel.totalTripsMade)", color: AppColors.blue)
                                .padding()
                                .overlay(Color.clear.accessibilityIdentifier("tripsCompleted"))
                        }
                        
                        HorizontalBarChart(data: viewModel.distancePerTransport, title: "Distance per vehicle", measurementUnit: "Km", color: AppColors.blue, sortByKey: true)
                            .padding()
                            .frame(height: 250)
                            .overlay(Color.clear.accessibilityIdentifier("distancePerVehicle"))
                        
                        HStack(alignment: .top) {
                            
                            PieChartView(data: viewModel.travelsPerTransport, title: "Most chosen Vehicle", color: AppColors.blue, icon: viewModel.mostChosenVehicle, colors: [AppColors.blue, AppColors.orange, AppColors.green, AppColors.red, AppColors.purple])
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
                .shadow(radius: 3, x: 0, y: 3)
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
