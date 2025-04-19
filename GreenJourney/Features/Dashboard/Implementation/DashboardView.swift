import SwiftUI
import SwiftData
import Charts

struct DashboardView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @StateObject private var viewModel: DashboardViewModel
    @Binding var navigationPath: NavigationPath
    private var modelContext: ModelContext
    private var serverService: ServerServiceProtocol
    private var firebaseAuthService: FirebaseAuthServiceProtocol
    
    @State private var legendTapped: Bool = false
    @State var isPresenting: Bool = false
    
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
                        UserPreferencesButtonView(navigationPath: $navigationPath, isPresenting: $isPresenting)
                    }
                }
                .padding(5)
                
                // expandible recaps
                DashboardDetailsNavigationView(viewModel: viewModel, navigationPath: $navigationPath, isPresenting: $isPresenting)
                    .frame(maxWidth: 800)
            }
            .padding(.horizontal)
        }
        .scrollClipDisabled(true)
        .clipShape(Rectangle())
        .background(colorScheme == .dark ? AppColors.backColorDark : AppColors.backColorLight)
        .onAppear() {
            isPresenting = false
            Task {
                viewModel.getUserTravels()
            }
        }
    }
}

private struct DashboardDetailsNavigationView: View {
    @ObservedObject var viewModel: DashboardViewModel
    @Binding var navigationPath: NavigationPath
    @Binding var isPresenting: Bool
    
    var body: some View {
        Button(action: {
            if !isPresenting {
                isPresenting = true
                navigationPath.append(NavigationDestination.Co2DetailsView(viewModel))
            }
        })
        {
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color(uiColor: .systemBackground))
                    .shadow(radius: 3, x: 0, y: 3)
                VStack (spacing:0){
                    HStack {
                        Text("CO\u{2082} Tracker")
                            .font(.title)
                            .foregroundStyle(AppColors.green)
                            .fontWeight(.semibold)
                            .scaledToFit()
                            .minimumScaleFactor(0.6)
                            .lineLimit(1)
                        Spacer()
                        Image(systemName: "chart.bar.xaxis.ascending")
                            .foregroundColor(AppColors.green)
                            .font(.title3)
                            .fontWeight(.bold)
                        Image(systemName: "chevron.right")
                            .foregroundColor(AppColors.green)
                            .font(.title3)
                            .fontWeight(.bold)
                    }
                    .padding()
                    InfoRowView(title: "Emitted", value: String(format: "%.0f", viewModel.co2Emitted) + " Kg", icon: "carbon.dioxide.cloud", isSystemIcon: true, color: AppColors.green, imageValue: false, imageValueString: nil)
                    
                    InfoRowView(title: "Compensated", value: String(format: "%.0f", viewModel.co2Compensated) + " Kg", icon: "leaf",  isSystemIcon: true, color: AppColors.green, imageValue: false, imageValueString: nil)
                }
                .padding(.bottom, 7)
            }
            .padding(EdgeInsets(top: 7, leading: 15, bottom: 7, trailing: 15))
            .overlay(Color.clear.accessibilityIdentifier("co2Tracker"))
        }
        Button(action: {
            if !isPresenting {
                isPresenting = true
                navigationPath.append(NavigationDestination.GeneralDetailsView(viewModel))
            }
        })
        {
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color(uiColor: .systemBackground))
                    .shadow(radius: 3, x: 0, y: 3)
                VStack (spacing:0){
                    HStack {
                        Text("Travels Recap")
                            .font(.title)
                            .foregroundStyle(AppColors.blue)
                            .fontWeight(.semibold)
                        Spacer()
                        Image(systemName: "chart.bar.xaxis.ascending")
                            .foregroundColor(AppColors.blue)
                            .font(.title3)
                            .fontWeight(.bold)
                        Image(systemName: "chevron.right")
                            .foregroundColor(AppColors.blue)
                            .font(.title3)
                            .fontWeight(.bold)
                    }
                    .padding()
                    InfoRowView(title: "Distance", value: String(format: "%.0f", viewModel.totalDistance) + " Km", icon: "road.lanes", isSystemIcon: true, color: AppColors.blue, imageValue: false, imageValueString: nil)
                    InfoRowView(title: "Travel time", value: viewModel.totalDurationString, icon: "clock", isSystemIcon: true, color: AppColors.blue, imageValue: false, imageValueString: nil)
                    
                }
                .padding(.bottom, 7)
            }
            .padding(EdgeInsets(top: 7, leading: 15, bottom: 7, trailing: 15))
            .overlay(Color.clear.accessibilityIdentifier("travelsRecap"))
        }
        Button(action: {
            if !isPresenting {
                isPresenting = true
                navigationPath.append(NavigationDestination.WorldExplorationView(viewModel))
            }
        })
        {
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color(uiColor: .systemBackground))
                    .shadow(radius: 3, x: 0, y: 3)
                VStack (spacing:0){
                    HStack {
                        Text("World Exploration")
                            .font(.title)
                            .foregroundStyle(AppColors.orange)
                            .fontWeight(.semibold)
                            .scaledToFit()
                            .minimumScaleFactor(0.6)
                            .lineLimit(1)
                        Spacer()
                        Image(systemName: "chart.bar.xaxis.ascending")
                            .foregroundColor(AppColors.orange)
                            .font(.title3)
                            .fontWeight(.bold)
                        Image(systemName: "chevron.right")
                            .foregroundColor(AppColors.orange)
                            .font(.title3)
                            .fontWeight(.bold)
                    }
                    .padding()
                    
                    InfoRowView(title: "Continents", value: "\(viewModel.visitedContinents.count) / 6", icon: "globe.europe.africa", isSystemIcon: true, color: AppColors.orange, imageValue: false, imageValueString: nil)
                    InfoRowView(title: "Countries", value: "\(viewModel.visitedCountries) / 195", icon: "mappin.and.ellipse", isSystemIcon: true, color: AppColors.orange, imageValue: false, imageValueString: nil)
                }
                .padding(.bottom, 7)
            }
            .padding(EdgeInsets(top: 7, leading: 15, bottom: 7, trailing: 15))
            .overlay(Color.clear.accessibilityIdentifier("worldExploration"))
        }
    }
}
