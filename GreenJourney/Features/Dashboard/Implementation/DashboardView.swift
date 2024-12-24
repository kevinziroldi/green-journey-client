import SwiftUI
import SwiftData
import Charts

struct DashboardView: View {
    @Binding var navigationPath: NavigationPath
    
    init(modelContext: ModelContext, navigationPath: Binding<NavigationPath>) {
        _navigationPath = navigationPath
    }
    
    @State private var legendTapped: Bool = false
    var user = User(firstName: "Matteo", lastName: "Volpari", firebaseUID: "", scoreShortDistance: 12, scoreLongDistance: 24)
    var body: some View {
        ZStack {
            ScrollView {
                Text("Dashboard")
                    .font(.system(size: 32).bold())
                    .padding()
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color(uiColor: .systemBackground))
                        .shadow(color: .blue.opacity(0.3), radius: 5, x: 0, y: 3)
                    VStack (spacing:0){
                        HStack {
                            Text("Badges")
                                .font(.title)
                                .foregroundStyle(.blue.opacity(0.8))
                                .fontWeight(.semibold)
                            Button(action: {
                                legendTapped = true
                            }) {
                                Image(systemName: "info.circle")
                                    .font(.title3)
                                    .foregroundStyle(.gray)
                            }
                            Spacer()
                        }
                        .padding(EdgeInsets(top: 15, leading: 15, bottom: 0, trailing: 0))
                        HStack{
                            BadgeView(badges: user.badges, dim: 80, inline: true)
                                .padding()
                            
                        }
                    }
                }
                .padding(EdgeInsets(top: 5, leading: 15, bottom: 7, trailing: 15))
                
                
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
                        
                        
                        InfoRow(title: "Co2 emitted", value: "570 Kg", icon: "carbon.dioxide.cloud", color: .red, imageValue: false, imageValueString: nil)
                        
                        InfoRow(title: "Co2 compensated", value: "523 Kg", icon: "leaf", color: .green, imageValue: false, imageValueString: nil)
                        
                        InfoRow(title: "Trees planted", value: "31", icon: "tree", color: Color(hue: 0.309, saturation: 1.0, brightness: 0.665), imageValue: false, imageValueString: nil)
                    }
                }
                .padding(EdgeInsets(top: 7, leading: 15, bottom: 7, trailing: 15))
                
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
                        
                        InfoRow(title: "Distance made", value: "542 Km", icon: "road.lanes", color: .indigo, imageValue: false, imageValueString: nil)
                        
                        InfoRow(title: "Most chosen vehicle", value: "", icon: "figure.wave", color: .indigo, imageValue: true, imageValueString: "bicycle")
                        
                        InfoRow(title: "Continents visited", value: "5 / 7", icon: "globe", color: .indigo, imageValue: false, imageValueString: nil)
                        
                    }
                }
                .padding(EdgeInsets(top: 7, leading: 15, bottom: 7, trailing: 15))
                
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color(uiColor: .systemBackground))
                        .shadow(color: .blue.opacity(0.3), radius: 5, x: 0, y: 3)
                    VStack (spacing:0){
                        Text("Travel time")
                            .font(.title)
                            .foregroundStyle(.blue.opacity(0.6))
                            .padding(EdgeInsets(top: 15, leading: 15, bottom: 0, trailing: 0))
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        InfoRow(title: "", value: "2 m, 24 d, 13 h, 58 min", icon: "clock", color: .blue, imageValue: false, imageValueString: nil)
                        
                    }
                }
                .padding(EdgeInsets(top: 7, leading: 15, bottom: 7, trailing: 15))
                
                
                BarChartView(title: "Trips completed", value: "27", data: [10, 12, 5, 15], labels: ["2020", "2021", "2022", "2023"], color: .pink.opacity(0.8))
                    .padding()
                BarChartView(title: "Distance made (Km)", value: "", data: [250, 427, 32, 500], labels: ["2020", "2021", "2022", "2023"], color: .indigo.opacity(0.8))
                    .padding()
            }
            .padding()
            .blur(radius: (legendTapped) ? 1 : 0)
            .allowsHitTesting(!legendTapped)
            
            if legendTapped {
                LegendView(onClose: {legendTapped = false})
            }
            
        }
        .background(.green.opacity(0.1))
    }
}


struct InfoRow: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let imageValue: Bool
    let imageValueString: String?
    
    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundColor(color)
            }
            
           
                Text(title)
                    .font(.system(size: 20).bold())
                    .foregroundColor(.primary)
            if title != "" {
                Spacer()
            }
                
                if !imageValue {
                    Text(value)
                        .font(.system(size: 25).bold())
                        .bold()
                        .foregroundColor(color.opacity(0.8))
            }
            else {
                if let imageValueString = imageValueString {
                    Image(systemName: imageValueString)
                        .resizable()
                        .fontWeight(.semibold)
                        .scaledToFit()
                        .frame(width: 45, height: 45)
                        .foregroundColor(color.opacity(0.8))
                }
                
            }
                
            
           
            Spacer()
        }
        .padding()
        
    }
}

struct BarChartView: View {
    let title: String
    let value: String
    let data: [Double]
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
                    .annotation(position: .bottom) {
                                            Text("\(labels[index])")
                                                .font(.caption)
                                                .fontWeight(.light)
                                                .foregroundColor(.secondary)
                                        }
                }
            }
            .chartYAxis(.hidden)
            .chartXAxis(.hidden)
            .frame(height: 250)
            .padding()
        }
        .background(Color(UIColor.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}
