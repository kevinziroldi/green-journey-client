import SwiftUI

struct ReturnOptionsView: View {
    let departure: String
    let arrival: String
    @ObservedObject var viewModel: TravelSearchViewModel
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @Binding var navigationPath: NavigationPath
    @State var isPresenting: Bool = false
    var body: some View {
        ScrollView {
            VStack {
                HeaderView(from: arrival, to: departure, date: viewModel.dateReturnPicked)
                    .overlay(Color.clear.accessibilityIdentifier("headerView"))
                
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.gray)
                
                if (!viewModel.returnOptionsAvailable){
                    CircularProgressView()
                        .padding(.top, 50)
                }
                else if (viewModel.returnOptions.isEmpty){
                    Text("We didn't find any travel option for this route. Please try again later. 😞")
                        .font(.system(size: 20))
                        .padding(.top, 50)
                        .padding(.horizontal)
                } else {
                    VStack {
                        ForEach (viewModel.returnOptions.indices, id: \.self) { option in
                            HStack {
                                Button (action: {
                                    if !isPresenting {
                                        isPresenting = true
                                        navigationPath.append(NavigationDestination.OptionDetailsView(arrival, departure,viewModel.returnOptions[option], viewModel, true))
                                    }
                                }) {
                                    OptionCardView(option: viewModel.returnOptions[option], viewModel: viewModel)
                                        .contentShape(Rectangle())
                                        .overlay(Color.clear.accessibilityIdentifier("returnOption_\(option)"))
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
        .onAppear {
            isPresenting = false
        }
        .background(colorScheme == .dark ? AppColors.backColorDark : AppColors.backColorLight)
    }
}
