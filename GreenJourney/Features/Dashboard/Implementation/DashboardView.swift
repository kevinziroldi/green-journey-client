import SwiftUI
import SwiftData
import Charts

struct DashboardView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.colorScheme) var colorScheme: ColorScheme
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
                
                // expandible recaps
                DashboardDetailsNavigationView(viewModel: viewModel)
                    .frame(maxWidth: 800)
            }
            .padding(.horizontal)
        }
        .background(colorScheme == .dark ? AppColors.backColorDark : AppColors.backColorLight)
        .onAppear() {
            Task {
                viewModel.getUserTravels()
            }
        }
    }
}

private struct DashboardDetailsNavigationView: View {
    @ObservedObject var viewModel: DashboardViewModel
    
    var body: some View {
        NavigationLink(destination: Co2DetailsView(viewModel: viewModel)) {
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color(uiColor: .systemBackground))
                    .shadow(color: .green.opacity(0.3), radius: 5, x: 0, y: 3)
                VStack (spacing:0){
                    HStack {
                        Text("Co2 tracker")
                            .font(.title)
                            .foregroundStyle(.green.opacity(0.8))
                            .fontWeight(.semibold)
                            .scaledToFit()
                            .minimumScaleFactor(0.6)
                            .lineLimit(1)
                        Spacer()
                        Image(systemName: "chart.bar.xaxis.ascending")
                            .foregroundColor(.green.opacity(0.8))
                            .font(.title2)
                            .fontWeight(.bold)
                        Image(systemName: "chevron.right")
                            .foregroundColor(.green.opacity(0.8))
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .padding()
                    InfoRowView(title: "Emitted", value: String(format: "%.0f", viewModel.co2Emitted) + " Kg", icon: "carbon.dioxide.cloud", color: .green, imageValue: false, imageValueString: nil)
                    
                    InfoRowView(title: "Compensated", value: String(format: "%.0f", viewModel.co2Compensated) + " Kg", icon: "leaf", color: .green, imageValue: false, imageValueString: nil)
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
                    .shadow(color: .teal.opacity(0.3), radius: 5, x: 0, y: 3)
                VStack (spacing:0){
                    HStack {
                        Text("Recap")
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
                    InfoRowView(title: "Distance", value: String(format: "%.0f", viewModel.totalDistance) + " Km", icon: "road.lanes", color: .teal, imageValue: false, imageValueString: nil)
                    InfoRowView(title: "Travel time", value: viewModel.totalDurationString, icon: "clock", color: .teal, imageValue: false, imageValueString: nil)
                    
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
                    .shadow(color: .orange.opacity(0.3), radius: 5, x: 0, y: 3)
                VStack (spacing:0){
                    HStack {
                        Text("World exploration")
                            .font(.title)
                            .foregroundStyle(.orange.opacity(0.6))
                            .fontWeight(.semibold)
                            .scaledToFit()
                            .minimumScaleFactor(0.6)
                            .lineLimit(1)
                        Spacer()
                        Image(systemName: "chart.bar.xaxis.ascending")
                            .foregroundColor(.orange.opacity(0.8))
                            .font(.title2)
                            .fontWeight(.bold)
                        Image(systemName: "chevron.right")
                            .foregroundColor(.orange.opacity(0.8))
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .padding()
                    
                    InfoRowView(title: "Visited continents", value: "\(viewModel.visitedContinents.count) / 6", icon: "globe", color: .orange, imageValue: false, imageValueString: nil)
                    InfoRowView(title: "Visited countries", value: "\(viewModel.visitedCountries) / 195", icon: "globe.europe.africa", color: .orange, imageValue: false, imageValueString: nil)
                }
                .padding(.bottom, 7)
            }
            .padding(EdgeInsets(top: 7, leading: 15, bottom: 7, trailing: 15))
            .overlay(Color.clear.accessibilityIdentifier("worldExploration"))
        }
    }
}
