import SwiftUI

struct OutwardOptionsView: View {
    let departure: String
    let arrival: String
    
    @ObservedObject var viewModel: TravelSearchViewModel
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        ScrollView {
            VStack {
                HeaderView(from: departure, to: arrival, date: viewModel.datePicked)
                    .overlay(Color.clear.accessibilityIdentifier("headerView"))
                
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.gray)
                
                if (!viewModel.optionsAvailable){
                    CircularProgressView()
                        .padding(.top, 50)
                }
                else if (viewModel.outwardOptions.isEmpty){
                    Text("We didn't find any travel option for this route. Please try again later. 😞")
                        .font(.system(size: 20))
                        .padding(.top, 50)
                        .padding(.horizontal)
                } else {
                    VStack {
                        ForEach (viewModel.outwardOptions.indices, id: \.self) { option in
                            HStack {
                                Button (action: {
                                    navigationPath.append(NavigationDestination.OptionDetailsView(departure, arrival,viewModel.outwardOptions[option], viewModel))
                                }) {
                                    OptionCardView(option: viewModel.outwardOptions[option], viewModel: viewModel)
                                        .contentShape(Rectangle())
                                        .overlay(Color.clear.accessibilityIdentifier("outwardOption_\(option)"))
                                }
                            }
                            .padding(.horizontal, 10)
                            .frame(maxWidth: 800)
                            
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .background(colorScheme == .dark ? AppColors.backColorDark : AppColors.backColorLight)
        .onAppear() {
            if !viewModel.selectedOption.isEmpty {
                viewModel.selectedOption = []
            }
        }
    }
}
