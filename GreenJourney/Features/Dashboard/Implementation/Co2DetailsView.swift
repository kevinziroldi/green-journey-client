import SwiftUI
import Charts

struct Co2DetailsView: View {
    @ObservedObject var viewModel: DashboardViewModel
    var body: some View {
        ScrollView {
            VStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color(uiColor: .systemBackground))
                        .shadow(color: .teal.opacity(0.3), radius: 5, x: 0, y: 3)
                    VStack (spacing:0){
                        Text("Co2 tracker")
                            .font(.title)
                            .foregroundStyle(.teal.opacity(0.8))
                            .padding(EdgeInsets(top: 15, leading: 15, bottom: 0, trailing: 0))
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        
                        InfoRow(title: "Co2 emitted", value: String(format: "%.0f", viewModel.co2Emitted) + " Kg", icon: "carbon.dioxide.cloud", color: .red, imageValue: false, imageValueString: nil)
                        
                        InfoRow(title: "Co2 compensated", value: String(format: "%.0f", viewModel.co2Compensated) + " Kg", icon: "leaf", color: .green, imageValue: false, imageValueString: nil)
                        
                        //InfoRow(title: "Trees planted", value: "\(viewModel.treesPlanted)", icon: "tree", color: Color(hue: 0.309, saturation: 1.0, brightness: 0.665), imageValue: false, imageValueString: nil)
                    }
                }
                .padding(EdgeInsets(top: 7, leading: 15, bottom: 7, trailing: 15))
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
                        SemicircleCo2Chart(progress: viewModel.computeProgress(), height: 170, width: 200, lineWidth: 16)
                            .padding(.top, 30)
                        HStack {
                            VStack {
                                Text("Compensated")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text(String(format: "%.0f", viewModel.co2Compensated) + " Kg")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(.leading, 20)
                            .foregroundStyle(.green)
                            VStack {
                                Text("Emitted")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text(String(format: "%.0f", viewModel.co2Emitted) + " Kg")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(.leading, 40)
                            .foregroundStyle(.red)
                        }
                    }
                    .padding()
                }
                .padding(EdgeInsets(top: 7, leading: 15, bottom: 7, trailing: 15))
                
                HorizontalBarChart(keys: viewModel.co2PerTransport.keys.sorted(), data: viewModel.co2PerTransport.keys.sorted().map{viewModel.co2PerTransport[$0]!}, title: "Co2 emitted per vehicle", color: .mint, measureUnit: "Kg")
                    .padding()
                    .frame(height: 200)

                DoubleBarChart(element1: "Co2 Emitted", keys: viewModel.keysToString(keys: viewModel.co2CompensatedPerYear.keys.sorted()), data1: viewModel.co2EmittedPerYear.keys.sorted().map{viewModel.co2EmittedPerYear[$0]!}, element2: "Co2 Compensated", data2: viewModel.co2CompensatedPerYear.keys.sorted().map{viewModel.co2CompensatedPerYear[$0]!}, title: "Co2 per year", measureunit: "Kg of CO2")
                    .padding()
                
                BarChartView(title: "Planted trees", value: "\(viewModel.treesPlanted)", data: viewModel.co2CompensatedPerYear.keys.sorted().map{Int(viewModel.co2CompensatedPerYear[$0]!/75)}, labels: viewModel.keysToString(keys: viewModel.co2CompensatedPerYear.keys.sorted()), color: AppColors.mainGreen)
                    .padding()
            }
            .padding(.horizontal)
        }
    }
}

