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
                    
                    VStack(spacing: 20) {
                        CompensationRecapView(viewModel: viewModel)
                            .padding(.horizontal)
                        
                        let co2PerTransportList = viewModel.co2PerTransport
                            .map{ (key, value) in
                                (key, value)
                            }
                        HorizontalBarChart(data: co2PerTransportList, title: "CO\u{2082} Emitted per Vehicle", measurementUnit: "Kg", color: AppColors.green, sortByKey: true)
                            .padding(.horizontal)
                            .frame(height: 250)
                            .overlay(Color.clear.accessibilityIdentifier("co2EmittedPerVehicle"))
                        
                        DoubleBarChart(element1: "CO\u{2082} Emitted", keys: viewModel.keysToString(keys: viewModel.co2CompensatedPerYearKg.keys.sorted()), data1: viewModel.co2EmittedPerYear.keys.sorted().map{viewModel.co2EmittedPerYear[$0]!}, color1: AppColors.orange, element2: "CO\u{2082} Compensated", data2: viewModel.co2CompensatedPerYearKg.keys.sorted().map{viewModel.co2CompensatedPerYearKg[$0]!}, color2: AppColors.blue, title: "CO\u{2082} per Year", measureunit: "Kg of CO\u{2082}")
                            .padding(.horizontal)
                            .overlay(Color.clear.accessibilityIdentifier("co2EmittedPerYear"))
                        
                        BarChartView(data: viewModel.co2CompensatedPerYearNumTrees, title: "Planted Trees", value: "\(viewModel.treesPlanted)", color: AppColors.green)
                            .padding(.horizontal)
                            .overlay(Color.clear.accessibilityIdentifier("plantedTreesPerYear"))
                        
                        Spacer()
                    }
                    .frame(maxWidth: 800)
                } else {
                    // iPad
                    
                    VStack(spacing: 0) {
                        HStack(spacing: 0) {
                            CompensationRecapView(viewModel: viewModel)
                                .padding()
                            
                            BarChartView(data: viewModel.co2CompensatedPerYearNumTrees, title: "Planted Trees", value: "\(viewModel.treesPlanted)", color: AppColors.green)
                                .padding()
                                .overlay(Color.clear.accessibilityIdentifier("plantedTreesPerYear"))
                        }
                        
                        let co2PerTransportList = viewModel.co2PerTransport
                            .map{ (key, value) in
                                (key, value)
                            }
                        HorizontalBarChart(data: co2PerTransportList, title: "CO\u{2082} Emitted per Vehicle", measurementUnit: "Kg", color: AppColors.green, sortByKey: true)
                            .padding()
                            .frame(height: 250)
                            .overlay(Color.clear.accessibilityIdentifier("co2EmittedPerVehicle"))
                        
                        DoubleBarChart(element1: "CO\u{2082} Emitted", keys: viewModel.keysToString(keys: viewModel.co2CompensatedPerYearKg.keys.sorted()), data1: viewModel.co2EmittedPerYear.keys.sorted().map{viewModel.co2EmittedPerYear[$0]!}, color1: AppColors.orange, element2: "CO\u{2082} Compensated", data2: viewModel.co2CompensatedPerYearKg.keys.sorted().map{viewModel.co2CompensatedPerYearKg[$0]!}, color2: AppColors.blue, title: "CO\u{2082} per Year", measureunit: "Kg of CO\u{2082}")
                            .padding()
                            .overlay(Color.clear.accessibilityIdentifier("co2EmittedPerYear"))
                        
                        Spacer()
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
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @ObservedObject var viewModel: DashboardViewModel
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(colorScheme == .dark ? AppColors.blockColorDark: Color(uiColor: .systemBackground))
                .shadow(radius: 3, x: 0, y: 3)
            VStack {
                Text("Compensation Recap")
                    .font(.title)
                    .foregroundStyle(AppColors.green)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                GeometryReader { geometry in
                    SemicircleCo2ChartView(progress: viewModel.computeProgress(), height: 170, width: 200, lineWidth: 16)
                        .position(x: geometry.size.width/2, y: geometry.size.height/2 )
                    VStack {
                        Text(String(format: "%.0f", viewModel.co2Compensated) + " Kg")
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                    .position(x: geometry.size.width/2 - 80, y: geometry.size.height/2 + 110)
                    .foregroundStyle(AppColors.green)
                    VStack {
                        Text(String(format: "%.0f", viewModel.co2Emitted) + " Kg")
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                    .foregroundStyle(.red.opacity(0.8))
                    .position(x: geometry.size.width/2 + 80, y: geometry.size.height/2 + 110)
                }
                .frame(height: 250)
            }
            .padding()
            .overlay(Color.clear.accessibilityIdentifier("co2CompenationRecap"))
        }
    }
}
