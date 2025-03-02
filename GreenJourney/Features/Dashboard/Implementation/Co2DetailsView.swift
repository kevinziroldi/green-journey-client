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
                            Spacer()
                            VStack {
                                Text("Compensated")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                Text(String(format: "%.0f", viewModel.co2Compensated) + " Kg")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundStyle(.green)
                            Spacer()
                            VStack {
                                Text("Emitted")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                Text(String(format: "%.0f", viewModel.co2Emitted) + " Kg")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundStyle(.red)
                            Spacer()
                        }
                    }
                    .padding()
                }
                .padding(EdgeInsets(top: 7, leading: 15, bottom: 7, trailing: 15))
                
                HorizontalBarChart(keys: viewModel.co2PerTransport.keys.sorted(), data: viewModel.co2PerTransport.keys.sorted().map{viewModel.co2PerTransport[$0]!}, title: "Co2 emitted per vehicle", color: .mint)
                    .padding()
                DoubleBarChart(element1: "Co2 Emitted", keys: viewModel.keysToString(keys: viewModel.co2CompensatedPerYear.keys.sorted()), data1: viewModel.co2EmittedPerYear.keys.sorted().map{viewModel.co2EmittedPerYear[$0]!}, element2: "Co2 Compensated", data2: viewModel.co2CompensatedPerYear.keys.sorted().map{viewModel.co2CompensatedPerYear[$0]!}, title: "Co2 per year", measureunit: "Kg of CO2")
                    .padding()
                
                BarChartView(title: "Planted trees", value: "\(viewModel.treesPlanted)", data: viewModel.co2CompensatedPerYear.keys.sorted().map{Int(viewModel.co2CompensatedPerYear[$0]!/75)}, labels: viewModel.keysToString(keys: viewModel.co2CompensatedPerYear.keys.sorted()), color: AppColors.mainGreen)
                    .padding()
            }
            .padding(.horizontal)
        }
    }
}


struct HorizontalBarChart: View {
    var keys: [String]
    var data: [Float64]
    var title: String
    let color: Color
    var body: some View {
        VStack {
            Text(title)
                .font(.title)
                .foregroundStyle(color.opacity(0.8))
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            Chart {
                ForEach(data.indices, id: \..self) { index in
                    BarMark(x: .value("Kg of Co2", data[index]), y: .value("Vehicle", keys[index]), width: .fixed(10))
                        .annotation(position: .trailing) {
                            Text(data[index].formatted() + " Kg")
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                            }
                }
                .foregroundStyle(color.gradient)
                .cornerRadius(10)
            }
            .fixedSize(horizontal: false, vertical: true)
            .chartYAxis {
                AxisMarks(preset: .extended, position: .leading) { _ in
                    AxisValueLabel(horizontalSpacing: 15)
                        .font(.headline)
                    
                }
            }
            .padding()
        }
        .frame(height: 200)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}

struct DoubleBarChart: View {
    let element1: String
    let data1: [String : Double]
    let element2: String
    let data2: [String : Double]
    let seriesData: [(element: String, data: [String: Double])]
    let title: String
    let measureUnit: String
    init(element1: String, keys: [String], data1: [Double], element2: String, data2: [Double], title: String, measureunit: String) {
        self.element1 = element1
        self.data1 = Dictionary(uniqueKeysWithValues: zip(keys, data1))
        self.element2 = element2
        self.data2 = Dictionary(uniqueKeysWithValues: zip(keys, data2))
        self.seriesData = [(element1, self.data1), (element2, self.data2)]
        self.title = title
        self.measureUnit = measureunit
    }
    var body: some View {
        VStack {
            Text(title)
                .font(.title)
                .foregroundStyle(.green.opacity(0.8))
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            Chart {
                ForEach(seriesData, id: \.0) { series in
                    ForEach(series.data.sorted(by: { $0.key < $1.key }), id: \.key) { item in
                        BarMark(x: .value("Year", item.key), y: .value("", item.value), width: .fixed(20))
                            .cornerRadius(5)
                            .annotation(position: .top) {
                                   if item.value > 0 {
                                    Text(String(format: "%.0f", item.value))
                                        .foregroundColor(.secondary)
                                        .font(.caption)
                                }
                            }
                    }
                    .foregroundStyle(by: .value("", series.element))
                    .position(by: .value("Element", series.element))
                }
            }
            .chartYAxisLabel {
                Text(measureUnit)
            }
            .frame(height: 300)
            .padding()
        }
        .background(Color(UIColor.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}
