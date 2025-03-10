import SwiftUI
import SwiftData
import Charts

struct DashboardView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
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
                    
                    if horizontalSizeClass == .compact {
                        UserPreferencesButtonView(navigationPath: $navigationPath, serverService: serverService, firebaseAuthService: firebaseAuthService)
                    }
                }
                .padding(5)
                
                if horizontalSizeClass == .compact {
               /*     // badges
                    UserBadgesView(legendTapped: $legendTapped, viewModel: viewModel, inline: false)
                    */
                    // expandible recaps
                    DashboardDetailsNavigationView(viewModel: viewModel)
                    
                /*    // scores
                    ScoresView(scoreLongDistance: viewModel.longDistanceScore, scoreShortDistance: viewModel.shortDistanceScore)*/
                } else {                    
                    // expandible recaps
                    DashboardDetailsNavigationView(viewModel: viewModel)
                }
            }
            .padding(.horizontal)
        }
        .onAppear() {
            Task {
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
                    .scaledToFit()
                    .minimumScaleFactor(0.8)
                    .lineLimit(1)
                    .foregroundColor(.primary)
                if title != "" {
                    Spacer()
                }
                if !imageValue {
                    Text(value)
                        .font(.system(size: 23).bold())
                        .bold()
                        .scaledToFit()
                        .minimumScaleFactor(0.8)
                        .lineLimit(1)
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
            }
            Spacer()
        }
        
        .padding(.horizontal)
        .padding(.vertical, 5)
        
    }
}

private struct DashboardDetailsNavigationView: View {
    @ObservedObject var viewModel: DashboardViewModel
    
    var body: some View {
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
                            .scaledToFit()
                            .minimumScaleFactor(0.6)
                            .lineLimit(1)
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
                    InfoRow(title: "Emitted", value: String(format: "%.0f", viewModel.co2Emitted) + " Kg", icon: "carbon.dioxide.cloud", color: .teal, imageValue: false, imageValueString: nil)
                    
                    InfoRow(title: "Compensated", value: String(format: "%.0f", viewModel.co2Compensated) + " Kg", icon: "leaf", color: .teal, imageValue: false, imageValueString: nil)
                }
                .padding(.bottom, 7)
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
                    InfoRow(title: "Travel time", value: viewModel.totalDurationString, icon: "clock", color: .indigo, imageValue: false, imageValueString: nil)
                    
                }
                .padding(.bottom, 7)
            }
            .padding(EdgeInsets(top: 7, leading: 15, bottom: 7, trailing: 15))
            .overlay(Color.clear.accessibilityIdentifier("travelsRecap"))
        }
        NavigationLink(destination: WorldExplorationView(viewModel: viewModel)) {
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color(uiColor: .systemBackground))
                    .shadow(color: .red.opacity(0.3), radius: 5, x: 0, y: 3)
                VStack (spacing:0){
                    HStack {
                        Text("World exploration")
                            .font(.title)
                            .foregroundStyle(.red.opacity(0.6))
                            .fontWeight(.semibold)
                            .scaledToFit()
                            .minimumScaleFactor(0.6)
                            .lineLimit(1)
                        Spacer()
                        Image(systemName: "chart.bar.xaxis.ascending")
                            .foregroundColor(.red.opacity(0.8))
                            .font(.title2)
                            .fontWeight(.bold)
                        Image(systemName: "chevron.right")
                            .foregroundColor(.red.opacity(0.8))
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .padding()
                    
                    InfoRow(title: "Visited continents", value: "\(viewModel.visitedContinents.count) / 6", icon: "globe", color: .red, imageValue: false, imageValueString: nil)
                    InfoRow(title: "Visited countries", value: "\(viewModel.visitedCountries) / 195", icon: "globe.europe.africa", color: .red, imageValue: false, imageValueString: nil)
                }
                .padding(.bottom, 7)
            }
            .padding(EdgeInsets(top: 7, leading: 15, bottom: 7, trailing: 15))
        }
    }
}

/*
private struct UserBadgesView: View {
    @Binding var legendTapped: Bool
    @ObservedObject var viewModel: DashboardViewModel
    var inline: Bool
    
    var body: some View {
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
                    BadgeView(badges: viewModel.badges, dim: 130, inline: inline)
                        .padding()
                }
            }
        }
        .padding(EdgeInsets(top: 5, leading: 15, bottom: 7, trailing: 15))
        .overlay(Color.clear.accessibilityIdentifier("userBadges"))
    }
}
*/
