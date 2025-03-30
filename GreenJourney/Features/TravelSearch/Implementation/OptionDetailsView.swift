import SwiftUI

struct OptionDetailsView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    let departure: String
    let arrival: String
    
    var option: TravelOption
    @ObservedObject var viewModel: TravelSearchViewModel
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        VStack {
            HeaderView(from: departure, to: arrival, date: option.segments.first?.dateTime)
            
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.gray)
            
            if horizontalSizeClass == .compact {
                // iOS
                
                ScrollView {
                    Co2RecapView(halfWidth: false, co2Emitted: option.getCo2Emitted(), numTrees: option.getNumTrees(), distance: option.getTotalDistance())
                        .padding(EdgeInsets(top: 10, leading: 15, bottom: 5, trailing: 15))
                        .overlay(Color.clear.accessibilityIdentifier("co2EmittedBox"))
                    
                    TravelRecapView(singleColumn: true, distance: option.getTotalDistance(), duration: option.getTotalDuration(), price: option.getTotalPrice(), greenPrice: option.getGreenPrice())
                        .padding()
                        .overlay(Color.clear.accessibilityIdentifier("travelRecap"))
                    
                    SegmentsView(segments: option.segments)
                        .padding(.top)
                    
                    Spacer()
                }
            } else {
                // iPadOS
                
                ScrollView {
                    HStack(alignment: .top) {
                        TravelRecapView(singleColumn: true, distance: option.getTotalDistance(), duration: option.getTotalDuration(), price: option.getTotalPrice(), greenPrice: option.getGreenPrice())
                            .padding()
                            .overlay(Color.clear.accessibilityIdentifier("travelRecap"))
                        
                        VStack {
                            Co2RecapView(halfWidth: true, co2Emitted: option.getCo2Emitted(), numTrees: option.getNumTrees(), distance: option.getTotalDistance())
                                .padding()
                                .overlay(Color.clear.accessibilityIdentifier("co2EmittedBox"))
                        }
                        .frame(maxHeight: .infinity, alignment: .top)
                    }
                    
                    SegmentsView(segments: option.segments)
                        .padding(.top)
                    
                    Spacer()
                }
            }
            VStack {
                if (!viewModel.oneWay) {
                    if (viewModel.selectedOption.isEmpty) {
                        Button(action: {
                            viewModel.selectedOption.append(contentsOf: option.segments)
                            navigationPath.append(NavigationDestination.ReturnOptionsView(departure, arrival, viewModel))
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(AppColors.mainColor)
                                Text("Proceed")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.white)
                                    .padding(10)
                            }
                            .fixedSize()
                        }
                        .accessibilityIdentifier("proceedButton")
                    }
                    else {
                        Button(action:  {
                            Task {
                                viewModel.selectedOption.append(contentsOf: option.segments)
                                await viewModel.saveTravel()
                                navigationPath = NavigationPath()
                            }
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(AppColors.mainColor)
                                Text("Save travel")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.white)
                                    .padding(10)
                            }
                            .fixedSize()
                        }
                        .accessibilityIdentifier("saveTravelButtonTwoWays")
                    }
                }
                else {
                    Button(action: {
                        Task {
                            viewModel.selectedOption.append(contentsOf: option.segments)
                            await viewModel.saveTravel()
                            navigationPath = NavigationPath()
                        }
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(AppColors.mainColor)
                            Text("Save travel")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                                .padding(10)
                        }
                        .fixedSize()
                    }
                    .accessibilityIdentifier("saveTravelButtonOneWay")
                }
            }
            .padding(10)
        }
        .background(colorScheme == .dark ? AppColors.backColorDark : AppColors.backColorLight)
    }
}

