import SwiftUI
import Charts

struct BarChartView: View {
    let title: String
    let value: String
    let data: [Int]
    let labels: [String]
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(title)
                    .font(.title)
                    .foregroundStyle(color.opacity(0.8))
                    .fontWeight(.semibold)
                Spacer()
                if value != "" {
                    ZStack {
                        Circle()
                            .fill(color.opacity(0.2).gradient)
                            .frame(width: 50, height: 50)
                        Text(value)
                            .font(.title)
                            .foregroundStyle(color)
                            .fontWeight(.semibold)
                    }
                }
                Spacer()
                Spacer()
            }
            .scaledToFit()
            .minimumScaleFactor(0.6)
            .lineLimit(1)
            .padding(EdgeInsets(top: 15, leading: 15, bottom: 0, trailing: 0))

            Chart {
                ForEach(data.indices, id: \..self) { index in
                    BarMark(
                        x: .value("Year", labels[index]),
                        y: .value("Trips", data[index])
                    )
                    .foregroundStyle(color.gradient)
                    .cornerRadius(10) // rounding of bars

                    // Adding label on top of each bar
                    .annotation(position: .top) {
                        Text("\(Int(data[index]))")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.primary.opacity(0.8))
                    }
                }
            }
            .frame(height: 250)
            .padding()
        }
        .background(Color(UIColor.systemBackground))
        .cornerRadius(15)
        .shadow(color: color.opacity(0.3), radius: 5, x: 0, y: 3)
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
                        .fontWeight(.semibold)
                        .font(.title)
                }
                Spacer()
                Spacer()
            }
            .scaledToFit()
            .minimumScaleFactor(0.6)
            .lineLimit(1)
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
        .shadow(color: color.opacity(0.3), radius: 5, x: 0, y: 3)
    }
}

struct HorizontalBarChart: View {
    var keys: [String]
    var data: [Float64]
    var title: String
    let color: Color
    let measureUnit: String
    var body: some View {
        VStack {
            Text(title)
                .font(.title)
                .foregroundStyle(color.opacity(0.8))
                .fontWeight(.semibold)
                .scaledToFit()
                .minimumScaleFactor(0.6)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.top)
            Chart {
                ForEach(data.indices, id: \..self) { index in
                    BarMark(x: .value("Value", data[index]), y: .value("Vehicle", keys[index]))
                        .annotation(position: .trailing) {
                            if data[index] > 0 {
                                Text(String(format: "%.0f", data[index]) + " " + measureUnit)
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                            }
                        }
                }
                .foregroundStyle(color.gradient)
                .cornerRadius(10)
            }
            .chartYAxis {
                AxisMarks(preset: .extended, position: .leading) { _ in
                    AxisValueLabel(horizontalSpacing: 15)
                        .font(.headline)
                    
                }
            }
            .padding()
        }
        .background(Color(UIColor.systemBackground))
        .cornerRadius(15)
        .shadow(color: color.opacity(0.3), radius: 5, x: 0, y: 3)
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
                .scaledToFit()
                .minimumScaleFactor(0.6)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.top)
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
            .frame(height: 250)
            .padding()
        }
        .background(Color(UIColor.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 5, x: 0, y: 3)
    }
}
