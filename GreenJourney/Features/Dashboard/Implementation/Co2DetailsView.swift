import SwiftUI
import Charts

struct Co2DetailsView: View {
    @ObservedObject var viewModel: DashboardViewModel
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    var body: some View {
        ScrollView {
            VStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color(uiColor: .systemBackground))
                        .shadow(color: .green.opacity(0.3), radius: 5, x: 0, y: 3)
                    VStack {
                        Text("Compensation recap")
                            .font(.title)
                            .foregroundStyle(.mint.opacity(0.8))
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
                            .foregroundStyle(.green)
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
                            .foregroundStyle(.red)
                            .position(x: geometry.size.width/2 + 90, y: geometry.size.height/2 + 100)
                        }
                        .frame(height: 250)
                    }
                    .padding()
                    .overlay(Color.clear.accessibilityIdentifier("co2CompenationRecap"))
                }
                .padding(EdgeInsets(top: 7, leading: 15, bottom: 7, trailing: 15))
                
                HorizontalBarChart(keys: viewModel.co2PerTransport.keys.sorted(), data: viewModel.co2PerTransport.keys.sorted().map{viewModel.co2PerTransport[$0]!}, title: "Co2 emitted per vehicle", color: .mint, measureUnit: "Kg")
                    .padding()
                    .frame(height: 250)
                    .overlay(Color.clear.accessibilityIdentifier("co2EmittedPerVehicle"))

                DoubleBarChart(element1: "Co2 Emitted", keys: viewModel.keysToString(keys: viewModel.co2CompensatedPerYear.keys.sorted()), data1: viewModel.co2EmittedPerYear.keys.sorted().map{viewModel.co2EmittedPerYear[$0]!}, element2: "Co2 Compensated", data2: viewModel.co2CompensatedPerYear.keys.sorted().map{viewModel.co2CompensatedPerYear[$0]!}, title: "Co2 per year", measureunit: "Kg of CO2")
                    .padding()
                    .overlay(Color.clear.accessibilityIdentifier("co2EmittedPerYear"))
                
                BarChartView(title: "Planted trees", value: "\(viewModel.treesPlanted)", data: viewModel.co2CompensatedPerYear.keys.sorted().map{Int(viewModel.co2CompensatedPerYear[$0]!/75)}, labels: viewModel.keysToString(keys: viewModel.co2CompensatedPerYear.keys.sorted()), color: AppColors.mainColor)
                    .padding()
                    .overlay(Color.clear.accessibilityIdentifier("plantedTreesPerYear"))
            }
            .padding(.horizontal)
        }
        .background(colorScheme == .dark ? AppColors.backColorDark : AppColors.backColorLight)
    }
}

