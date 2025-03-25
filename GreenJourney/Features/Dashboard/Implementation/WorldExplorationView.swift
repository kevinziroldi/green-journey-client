import SwiftUI

struct WorldExplorationView: View {
    @ObservedObject var viewModel: DashboardViewModel
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    var body: some View {
        ScrollView {
            VStack {
                VStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color(uiColor: .systemBackground))
                            .shadow(color: AppColors.orange.opacity(0.3), radius: 5, x: 0, y: 3)
                        VStack(spacing:0) {
                            Text("Continents")
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
                    .padding(EdgeInsets(top: 7, leading: 15, bottom: 7, trailing: 15))
                    
                    HorizontalBarChart(keys: viewModel.countriesPerContinent.keys.sorted(), data: viewModel.countriesPerContinent.keys.sorted().map{Float64(viewModel.countriesPerContinent[$0]!)}, title: "Countries", color: AppColors.orange, measureUnit: "")
                        .frame(height: 250)
                        .padding()
                        .overlay(Color.clear.accessibilityIdentifier("countriesPerContinent"))
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color(uiColor: .systemBackground))
                            .shadow(color: AppColors.orange.opacity(0.3), radius: 5, x: 0, y: 3)
                        VStack (spacing:0){
                            Text("Visited countries")
                                .font(.title)
                                .foregroundStyle(AppColors.orange)
                                .padding()
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            InfoRowView(title: "", value: "\(viewModel.visitedCountries) / 195", icon: "mappin.and.ellipse", isSystemIcon: true, color: AppColors.orange, imageValue: false, imageValueString: nil)
                        }
                        .padding(.bottom, 7)
                    }
                    .padding(EdgeInsets(top: 7, leading: 15, bottom: 7, trailing: 15))
                    .overlay(Color.clear.accessibilityIdentifier("visitedCountries"))
                }.frame(maxWidth: 800)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
        }
        .background(colorScheme == .dark ? AppColors.backColorDark : AppColors.backColorLight)
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
