import SwiftUI
import Charts

struct Co2DetailsView: View {
    @ObservedObject var viewModel: DashboardViewModel
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        ScrollView {
            VStack {
                if horizontalSizeClass == .compact {
                    // iPhone
                    
                    VStack {
                        CompensationRecapView(viewModel: viewModel)
                        
                        HorizontalBarChart(data: viewModel.co2PerTransport, title: "Co2 emitted per vehicle", measurementUnit: "Kg", color: AppColors.green, sortData: true)
                            .padding()
                            .frame(height: 250)
                            .overlay(Color.clear.accessibilityIdentifier("co2EmittedPerVehicle"))
                                                
                        DoubleBarChart(element1: "Co2 Emitted", keys: viewModel.keysToString(keys: viewModel.co2CompensatedPerYearKg.keys.sorted()), data1: viewModel.co2EmittedPerYear.keys.sorted().map{viewModel.co2EmittedPerYear[$0]!}, color1: AppColors.orange, element2: "Co2 Compensated", data2: viewModel.co2CompensatedPerYearKg.keys.sorted().map{viewModel.co2CompensatedPerYearKg[$0]!}, color2: AppColors.blue, title: "Co2 per year", measureunit: "Kg of CO2")
                            .padding()
                            .overlay(Color.clear.accessibilityIdentifier("co2EmittedPerYear"))
                        
                        
                        BarChartView(data: viewModel.co2CompensatedPerYearNumTrees, title: "Planted trees", value: "\(viewModel.treesPlanted)", color: AppColors.green)
                            .padding()
                            .overlay(Color.clear.accessibilityIdentifier("plantedTreesPerYear"))
                    }
                    .frame(maxWidth: 800)
                } else {
                    // iPad
                    
                    VStack {
                        HStack {
                            CompensationRecapView(viewModel: viewModel)
                            
                            BarChartView(data: viewModel.co2CompensatedPerYearNumTrees, title: "Planted trees", value: "\(viewModel.treesPlanted)", color: AppColors.green)
                                .padding()
                                .overlay(Color.clear.accessibilityIdentifier("plantedTreesPerYear"))
                        }
                        
                        HorizontalBarChart(data: viewModel.co2PerTransport, title: "Co2 emitted per vehicle", measurementUnit: "Kg", color: AppColors.green, sortData: true)
                            .padding()
                            .frame(height: 250)
                            .overlay(Color.clear.accessibilityIdentifier("co2EmittedPerVehicle"))
                        
                        DoubleBarChart(element1: "Co2 Emitted", keys: viewModel.keysToString(keys: viewModel.co2CompensatedPerYearKg.keys.sorted()), data1: viewModel.co2EmittedPerYear.keys.sorted().map{viewModel.co2EmittedPerYear[$0]!}, color1: AppColors.orange, element2: "Co2 Compensated", data2: viewModel.co2CompensatedPerYearKg.keys.sorted().map{viewModel.co2CompensatedPerYearKg[$0]!}, color2: AppColors.blue, title: "Co2 per year", measureunit: "Kg of CO2")
                            .padding()
                            .overlay(Color.clear.accessibilityIdentifier("co2EmittedPerYear"))
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

private struct CompensationRecapView: View {
    @ObservedObject var viewModel: DashboardViewModel
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(uiColor: .systemBackground))
                .shadow(color: AppColors.green.opacity(0.3), radius: 5, x: 0, y: 3)
            VStack {
                Text("Compensation recap")
                    .font(.title)
                    .foregroundStyle(AppColors.green)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                GeometryReader { geometry in
                    SemicircleCo2ChartView(progress: viewModel.computeProgress(), height: 170, width: 200, lineWidth: 16)
                        .position(x: geometry.size.width/2, y: geometry.size.height/2 - 20)
                    VStack {
                        Text("Compensated")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .scaledToFit()
                            .minimumScaleFactor(0.6)
                            .lineLimit(1)
                        Text(String(format: "%.0f", viewModel.co2Compensated) + " Kg")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                    .position(x: geometry.size.width/2 - 90, y: geometry.size.height/2 + 100)
                    .foregroundStyle(AppColors.green)
                    VStack {
                        Text("Emitted")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .scaledToFit()
                            .minimumScaleFactor(0.6)
                            .lineLimit(1)
                        Text(String(format: "%.0f", viewModel.co2Emitted) + " Kg")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                    .foregroundStyle(.red.opacity(0.8))
                    .position(x: geometry.size.width/2 + 90, y: geometry.size.height/2 + 100)
                }
                .frame(height: 250)
            }
            .padding()
            .overlay(Color.clear.accessibilityIdentifier("co2CompenationRecap"))
        }
        .padding(EdgeInsets(top: 7, leading: 15, bottom: 7, trailing: 15))
    }
}
