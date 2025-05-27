import SwiftUI

struct WorldExplorationView: View {
    @ObservedObject var viewModel: DashboardViewModel
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        ScrollView {
            VStack {
                if horizontalSizeClass == .compact {
                    // iOS
                    
                    VStack(spacing: 20) {
                        VisitedContinentsView(viewModel: viewModel)
                            .padding(.horizontal)
                        
                        let countriesPerContinentList = viewModel.countriesPerContinent
                            .map{ (key, value) in
                                (key, value)
                            }
                        HorizontalBarChart(data: countriesPerContinentList, title: "Continents", measurementUnit: "", color: AppColors.orange, sortByKey: true)
                            .frame(height: 250)
                            .padding(.horizontal)
                            .overlay(Color.clear.accessibilityIdentifier("countriesPerContinent"))
                        
                        VisitedCountriesView(viewModel: viewModel)
                            .padding(.horizontal)
                        
                        HorizontalBarChart(data: viewModel.mostVisitedCountries, title: "Most visited Countries", measurementUnit: "", color: AppColors.orange, sortByKey: false)
                            .frame(height: 250)
                            .padding(.horizontal)
                            .overlay(Color.clear.accessibilityIdentifier("mostVisitedCountries"))
                        
                        Spacer()
                    }
                } else {
                    // iPadOS
                    
                    VStack(spacing: 0) {
                        VisitedContinentsView(viewModel: viewModel)
                            .padding()
                        
                        let countriesPerContinentList = viewModel.countriesPerContinent
                            .map{ (key, value) in
                                (key, value)
                            }
                        HorizontalBarChart(data: countriesPerContinentList, title: "Countries", measurementUnit: "", color: AppColors.orange, sortByKey: true)
                            .frame(height: 250)
                            .padding()
                            .overlay(Color.clear.accessibilityIdentifier("countriesPerContinent"))
                        
                        HStack(alignment: .top, spacing: 0) {
                            HorizontalBarChart(data: viewModel.mostVisitedCountries, title: "Most visited Countries", measurementUnit: "", color: AppColors.orange, sortByKey: false)
                                .frame(height: 250)
                                .overlay(Color.clear.accessibilityIdentifier("mostVisitedCountries"))
                                .padding()
                            
                            VisitedCountriesView(viewModel: viewModel)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding()
                        }
                        
                        Spacer()
                    }
                    .frame(maxWidth: 800)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
        }
        .background(colorScheme == .dark ? AppColors.backColorDark : AppColors.backColorLight)
    }
}

private struct VisitedContinentsView: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme

    @ObservedObject var viewModel: DashboardViewModel
    var body: some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(colorScheme == .dark ? AppColors.blockColorDark: Color(uiColor: .systemBackground))
                    .shadow(radius: 3, x: 0, y: 3)
                VStack(spacing:0) {
                    Text("World Exploration")
                        .font(.title)
                        .foregroundStyle(AppColors.orange)
                        .padding(EdgeInsets(top: 15, leading: 15, bottom: 0, trailing: 0))
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack {
                        HStack {
                            ContinentImage(image: "Europe", description: "Europe", visited: viewModel.visitedContinents.contains("Europe"))
                            ContinentImage(image: "Africa", description: "Africa", visited: viewModel.visitedContinents.contains("Africa"))
                            ContinentImage(image: "NorthAmerica", description: "North America", visited: viewModel.visitedContinents.contains("North America"))
                        }
                        HStack {
                            ContinentImage(image: "SouthAmerica", description: "South America", visited: viewModel.visitedContinents.contains("South America"))
                            ContinentImage(image: "Asia", description: "Asia", visited: viewModel.visitedContinents.contains("Asia"))
                            ContinentImage(image: "Oceania", description: "Oceania", visited: viewModel.visitedContinents.contains("Oceania"))
                        }
                    }
                    .padding()
                }
                .overlay(Color.clear.accessibilityIdentifier("visitedContinents"))
            }
        }
    }
}

private struct ContinentImage: View {
    let image: String
    let description: String
    let visited: Bool
    var body: some View {
        VStack {
            if visited {
                Image(image)
                    .resizable()
                    .scaledToFit()
            }
            else {
                Image(image + "Locked")
                    .resizable()
                    .scaledToFit()
            }
            Text(description)
                .font(.headline )
                .foregroundStyle(visited ? .primary : .secondary)
        }
    }
}

private struct VisitedCountriesView: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme

    @ObservedObject var viewModel: DashboardViewModel
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(colorScheme == .dark ? AppColors.blockColorDark: Color(uiColor: .systemBackground))
                .shadow(radius: 3, x: 0, y: 3)
            VStack (spacing:0){
                Text("Visited Countries")
                    .font(.title)
                    .foregroundStyle(AppColors.orange)
                    .padding()
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                InfoRowView(title: "", value: "\(viewModel.visitedCountries) / 195", icon: "mappin.and.ellipse", isSystemIcon: true, color: AppColors.orange, imageValue: false, imageValueString: nil)
            }
            .padding(.bottom, 7)
        }
        .overlay(Color.clear.accessibilityIdentifier("visitedCountries"))
    }
}
