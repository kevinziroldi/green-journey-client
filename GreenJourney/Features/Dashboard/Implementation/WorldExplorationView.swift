import SwiftUI

struct WorldExplorationView: View {
    @ObservedObject var viewModel: DashboardViewModel
    var body: some View {
        ScrollView {
            VStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color(uiColor: .systemBackground))
                        .shadow(color: .teal.opacity(0.3), radius: 5, x: 0, y: 3)
                    VStack (spacing:0){
                        Text("Continents")
                            .font(.title)
                            .foregroundStyle(.teal.opacity(0.8))
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
                }
                .padding(EdgeInsets(top: 7, leading: 15, bottom: 7, trailing: 15))
               
                HorizontalBarChart(keys: viewModel.countriesPerContinent.keys.sorted(), data: viewModel.countriesPerContinent.keys.sorted().map{Float64(viewModel.countriesPerContinent[$0]!)}, title: "Countries", color: .yellow, measureUnit: "")
                    .frame(height: 250)
                    .padding()
                
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color(uiColor: .systemBackground))
                        .shadow(color: .orange.opacity(0.3), radius: 5, x: 0, y: 3)
                    VStack (spacing:0){
                        Text("Visited countries")
                            .font(.title)
                            .foregroundStyle(.orange.opacity(0.8))
                            .padding()
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        InfoRowView(title: "", value: "\(viewModel.visitedCountries) / 195", icon: "globe.europe.africa", color: .orange, imageValue: false, imageValueString: nil)
                    }
                    .padding(.bottom, 7)
                }
                .padding(EdgeInsets(top: 7, leading: 15, bottom: 7, trailing: 15))
                
            }
            .padding(.horizontal)
        }
    }
}


struct ContinentImage: View {
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
