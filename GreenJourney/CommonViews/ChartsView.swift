import SwiftUI
import Charts

struct ChartElement: Identifiable {
    let id = UUID()
    let name: String
    let value: Double
    let color: Color
}

struct PieChartView: View {
    var title: String
    let color: Color
    let icon: String
    var colors: [Color]
    private var colorCorrespondences: [String : Color]
    var chartData: [ChartElement]
    
    init(data: [String: Int], title: String, color: Color, icon: String, colors: [Color]) {
        self.title = title
        self.color = color
        self.icon = icon
        self.colors = colors
        
        // sort data
        let sortedData = data.sorted { $0.key < $1.key }
        
        // buil data structures
        self.colorCorrespondences = [:]
        self.chartData = []
        for (i, element) in sortedData.enumerated() {
            let elementColor = i < colors.count ? colors[i] : color
            let chartElement = ChartElement(name: element.key, value: Double(element.value), color: elementColor)
            self.chartData.append(chartElement)
            self.colorCorrespondences[element.key] = elementColor
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Text(title)
                    .font(.title)
                    .foregroundStyle(color)
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
                ForEach(chartData) { chartElement in
                    SectorMark(angle: .value("Distance", chartElement.value), angularInset: 2)
                        .foregroundStyle(chartElement.color.gradient)
                        .cornerRadius(5)
                        .annotation(position: .overlay) {
                            if chartElement.value != 0 {
                                Text("\(Int(chartElement.value))")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                            }
                        }
                }
            }
            .padding()
            .padding(.bottom)
            
            HStack(spacing: 10) {
                ForEach(chartData) { chartElement in
                    HStack {
                        Circle()
                            .fill(chartElement.color)
                            .frame(width: 12, height: 12)
                        Text(chartElement.name)
                            .foregroundColor(.primary)
                            .font(.system(size: 15, weight: .semibold))
                    }
                }
            }
            .padding(.bottom)
        }
        .frame(height: 350)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 3, x: 0, y: 3)
    }
}

struct BarChartView: View {
    let title: String
    let value: String
    let color: Color
    
    var chartData: [ChartElement]
    
    init(data: [String: Int], title: String, value: String, color: Color) {
        self.title = title
        self.value = value
        self.color = color
        
        // sort data
        let sortedData = data.sorted { $0.key < $1.key }
        
        // buil data structures
        self.chartData = []
        for (_, element) in sortedData.enumerated() {
            let chartElement = ChartElement(name: element.key, value: Double(element.value), color: color)
            self.chartData.append(chartElement)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(title)
                    .font(.title)
                    .foregroundStyle(color)
                    .fontWeight(.semibold)
                    .frame(height: 50)
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
                ForEach(chartData) { chartElement in
                    BarMark(
                        x: .value("Year", chartElement.name),
                        y: .value("Trips", Int(chartElement.value))
                    )
                    .foregroundStyle(chartElement.color.gradient)
                    .cornerRadius(10)
                    .annotation(position: .top) {
                        Text("\(Int(chartElement.value))")
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
        .shadow(radius: 3, x: 0, y: 3)
    }
}

struct HorizontalBarChart: View {
    var title: String
    let color: Color
    let measureUnit: String
    
    var chartData: [ChartElement]
    
    init(data: [String: Float64], title: String, measurementUnit: String, color: Color, sortByKey: Bool) {
        self.title = title
        self.measureUnit = measurementUnit
        self.color = color
        
        // buil data structures
        self.chartData = []
        
        if sortByKey {
            // sort data
            let sortedData = data.sorted { $0.key < $1.key }
            for (_, element) in sortedData.enumerated() {
                let chartElement = ChartElement(name: element.key, value: Double(element.value), color: color)
                self.chartData.append(chartElement)
            }
        } else {
            let sortedData = data.sorted { $0.value > $1.value }
            for (_, element) in sortedData.enumerated() {
                let chartElement = ChartElement(name: element.key, value: Double(element.value), color: color)
                self.chartData.append(chartElement)
            }
        }
    }
    
    var body: some View {
        VStack {
            Text(title)
                .font(.title)
                .foregroundStyle(color)
                .fontWeight(.semibold)
                .scaledToFit()
                .minimumScaleFactor(0.6)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.top)
            
            
            Chart {
                ForEach(chartData) { chartElement in
                    BarMark(x: .value("Value", chartElement.value), y: .value("Vehicle", chartElement.name))
                        .annotation(position: .trailing) {
                            if chartElement.value > 0 {
                                Text(String(format: "%.0f", chartElement.value) + " " + measureUnit)
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
        .shadow(radius: 3, x: 0, y: 3)
    }
}

struct DoubleBarChart: View {
    let element1: String
    let data1: [String : Double]
    let color1: Color
    let element2: String
    let data2: [String : Double]
    let color2: Color
    let seriesData: [(element: String, data: [String: Double])]
    let title: String
    let measureUnit: String
    private let colorCorrespondences: [String : Color]
    
    init(element1: String, keys: [String], data1: [Double], color1: Color, element2: String, data2: [Double], color2: Color, title: String, measureunit: String) {
        self.element1 = element1
        self.data1 = Dictionary(uniqueKeysWithValues: zip(keys, data1))
        self.color1 = color1
        self.element2 = element2
        self.data2 = Dictionary(uniqueKeysWithValues: zip(keys, data2))
        self.color2 = color2
        self.seriesData = [(element1, self.data1), (element2, self.data2)]
        self.title = title
        self.measureUnit = measureunit
        self.colorCorrespondences = [element1 : color1, element2 : color2]
    }
    
    var body: some View {
        VStack {
            Text(title)
                .font(.title)
                .foregroundStyle(AppColors.green)
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
            .chartForegroundStyleScale(
                [
                    element1: color1.gradient,
                    element2: color2.gradient
                ]
            )
            .frame(height: 250)
            .padding()
            .chartLegend {
                HStack(spacing: 10) {
                    ForEach(seriesData, id: \.0) { series in
                        HStack {
                            Circle()
                                .fill(colorCorrespondences[series.element] ?? .gray)
                                .frame(width: 12, height: 12)
                            Text(series.element)
                                .foregroundColor(.primary)
                                .font(.system(size: 15, weight: .semibold))
                        }
                    }
                }
                .padding(.top)
            }
        }
        .background(Color(UIColor.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 3, x: 0, y: 3)
    }
}
