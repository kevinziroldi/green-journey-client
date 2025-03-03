import SwiftUI
import SwiftData
import Charts

struct DashboardView: View {
    @StateObject var viewModel: DashboardViewModel
    @Binding var navigationPath: NavigationPath
    private var modelContext: ModelContext
    private var serverService: ServerServiceProtocol
    private var firebaseAuthService: FirebaseAuthServiceProtocol
    
    @State private var legendTapped: Bool = false
    
    init(modelContext: ModelContext, navigationPath: Binding<NavigationPath>, serverService: ServerServiceProtocol, firebaseAuthService: FirebaseAuthServiceProtocol) {
        _viewModel = StateObject(wrappedValue: DashboardViewModel(modelContext: modelContext, serverService: serverService))
        _navigationPath = navigationPath
        self.serverService = serverService
        self.modelContext = modelContext
        self.firebaseAuthService = firebaseAuthService
    }
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack {
                    HStack {
                        Text("Dashboard")
                            .font(.system(size: 32).bold())
                            .padding()
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .accessibilityIdentifier("dashboardTitle")
                        Spacer()
                        
                        NavigationLink(destination: UserPreferencesView(modelContext: modelContext, navigationPath: $navigationPath, serverService: serverService, firebaseAuthService: firebaseAuthService)) {
                            Image(systemName: "person")
                                .font(.title)
                                .foregroundStyle(AppColors.mainGreen)
                        }
                        .accessibilityIdentifier("userPreferencesButton")
                    }
                    .padding(5)
                    
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
                                BadgeView(badges: viewModel.badges, dim: 130, inline: false)
                                    .padding()
                            }
                        }
                    }
                    .padding(EdgeInsets(top: 5, leading: 15, bottom: 7, trailing: 15))
                    .overlay(Color.clear.accessibilityIdentifier("userBadges"))
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color(uiColor: .systemBackground))
                            .shadow(color: .pink.opacity(0.3), radius: 5, x: 0, y: 3)
                        VStack (spacing:0){
                            Text("Scores")
                                .font(.title)
                                .foregroundStyle(.pink.opacity(0.8))
                                .padding(EdgeInsets(top: 15, leading: 15, bottom: 0, trailing: 0))
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            InfoRow(title: "Short distance", value: String(format: "%.1f", viewModel.shortDistanceScore), icon: "trophy", color: .blue, imageValue: false, imageValueString: nil)
                            
                            InfoRow(title: "Long distance", value: String(format: "%.1f", viewModel.longDistanceScore), icon: "trophy", color: .pink, imageValue: false, imageValueString: nil)
                        }
                    }
                    .padding(EdgeInsets(top: 7, leading: 15, bottom: 7, trailing: 15))
                    
                    NavigationLink(destination: Co2DetailsView(viewModel: viewModel)) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color(uiColor: .systemBackground))
                                .shadow(color: .teal.opacity(0.3), radius: 5, x: 0, y: 3)
                            VStack (spacing:0){
                                HStack {
                                    Text("Co2 tracker")
                                        .font(.title)
                                        .foregroundStyle(.teal.opacity(0.8))
                                        .fontWeight(.semibold)
                                    Spacer()
                                    Image(systemName: "chart.bar.xaxis.ascending")
                                        .foregroundColor(.teal.opacity(0.8))
                                        .font(.title2)
                                        .fontWeight(.bold)
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.teal.opacity(0.8))
                                        .font(.title2)
                                        .fontWeight(.bold)
                                }
                                .padding()
                                InfoRow(title: "Co2 emitted", value: String(format: "%.0f", viewModel.co2Emitted) + " Kg", icon: "carbon.dioxide.cloud", color: .teal, imageValue: false, imageValueString: nil)
                                
                                InfoRow(title: "Co2 compensated", value: String(format: "%.0f", viewModel.co2Compensated) + " Kg", icon: "leaf", color: .teal, imageValue: false, imageValueString: nil)
                            }
                        }
                        .padding(EdgeInsets(top: 7, leading: 15, bottom: 7, trailing: 15))
                        .overlay(Color.clear.accessibilityIdentifier("co2Tracker"))
                    }
                    NavigationLink(destination: GeneralDetailsView(viewModel: viewModel)) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color(uiColor: .systemBackground))
                                .shadow(color: .indigo.opacity(0.3), radius: 5, x: 0, y: 3)
                            VStack (spacing:0){
                                HStack {
                                    Text("Recap")
                                        .font(.title)
                                        .foregroundStyle(.indigo.opacity(0.8))
                                        .fontWeight(.semibold)
                                    Spacer()
                                    Image(systemName: "chart.bar.xaxis.ascending")
                                        .foregroundColor(.indigo.opacity(0.8))
                                        .font(.title2)
                                        .fontWeight(.bold)
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.indigo.opacity(0.8))
                                        .font(.title2)
                                        .fontWeight(.bold)
                                }
                                .padding()
                                InfoRow(title: "Distance made", value: String(format: "%.0f", viewModel.totalDistance) + " Km", icon: "road.lanes", color: .indigo, imageValue: false, imageValueString: nil)
                                InfoRow(title: "", value: viewModel.totalDurationString, icon: "clock", color: .indigo, imageValue: false, imageValueString: nil)
                                
                            }
                        }
                        .padding(EdgeInsets(top: 7, leading: 15, bottom: 7, trailing: 15))
                        .overlay(Color.clear.accessibilityIdentifier("travelsRecap"))
                    }
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
                            
                            InfoRow(title: "Continents visited", value: "\(viewModel.visitedContinents) / 5", icon: "globe", color: .indigo, imageValue: false, imageValueString: nil)

                        }
                        
                    }
                    .padding(EdgeInsets(top: 7, leading: 15, bottom: 7, trailing: 15))
                    .overlay(Color.clear.accessibilityIdentifier("travelTime"))
                    
                    
                }
                .padding(.horizontal)
            }
            .blur(radius: (legendTapped) ? 1 : 0)
            .allowsHitTesting(!legendTapped)
            
            if legendTapped {
                LegendBadgeView(onClose: {legendTapped = false})
            }
            
        }
        .onAppear() {
            Task {
                await viewModel.getUserFromServer()
                viewModel.getUserTravels()
            }
        }
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
        .padding(.horizontal)
        .padding(.vertical, 5)
        
    }
}

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
