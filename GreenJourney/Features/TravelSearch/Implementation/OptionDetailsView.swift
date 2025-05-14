import SwiftUI

struct OptionDetailsView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    let departure: String
    let arrival: String
    
    var option: TravelOption
    @ObservedObject var viewModel: TravelSearchViewModel
    @Binding var navigationPath: NavigationPath
    
    @State var buttonTapped: Bool = false
    
    var body: some View {
        VStack {
            if horizontalSizeClass == .compact {
                // iOS
                
                ScrollView {
                    HeaderView(from: departure, to: arrival, date: option.segments.first?.dateTime)
                    
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.gray)
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
                        HeaderView(from: departure, to: arrival, date: option.segments.first?.dateTime)
                        
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.gray)
                    VStack {
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
                        
                        HStack(alignment: .top) {
                            VStack(alignment: .leading) {
                                HStack {
                                    Text("Segments")
                                        .font(.title)
                                        .fontWeight(.semibold)
                                        .accessibilityIdentifier("segmentsTitle")
                                    Spacer()
                                }
                                .fixedSize()
                                .padding(.top)
                                
                                SegmentsView(segments: option.segments)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .frame(maxWidth: 370)
                            Spacer()
                        }
                        .padding(.top)
                        .padding(.leading, 10)
                        
                        Spacer()
                    }
                    .frame(maxWidth: 800)
                }
            }
            VStack {
                if (!viewModel.oneWay) {
                    if (viewModel.selectedOption.isEmpty) {
                        Button(action: {
                            if !buttonTapped {
                                buttonTapped = true
                                viewModel.selectedOption.append(contentsOf: option.segments)
                                navigationPath.append(NavigationDestination.ReturnOptionsView(departure, arrival, viewModel))
                            }
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
                        .disabled(buttonTapped)
                        .padding(.bottom)
                        .accessibilityIdentifier("proceedButton")
                    }
                    else {
                        Button(action:  {
                            if !buttonTapped {
                                buttonTapped = true
                                Task {
                                    viewModel.selectedOption.append(contentsOf: option.segments)
                                    await viewModel.saveTravel()
                                    if !viewModel.errorOccurred {
                                        navigationPath = NavigationPath()
                                    }
                                }
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
                        .disabled(buttonTapped)
                        .padding(.bottom)
                        .accessibilityIdentifier("saveTravelButtonTwoWays")
                    }
                }
                else {
                    Button(action: {
                        Task {
                            print("ONE WAY - SAVE")
                            for segment in option.segments {
                                print(segment.departureCity, segment.destinationCity)
                            }
                            viewModel.selectedOption.append(contentsOf: option.segments)
                            await viewModel.saveTravel()
                            if !viewModel.errorOccurred {
                                navigationPath = NavigationPath()
                            }
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
                    .disabled(buttonTapped)
                    .padding(.bottom)
                    .accessibilityIdentifier("saveTravelButtonOneWay")
                }
            }
            .padding(10)
        }
        .onAppear {
            buttonTapped = false
        }
        .alert(isPresented: $viewModel.errorOccurred) {
            Alert(
                title: Text("Something went wrong 😞"),
                message: Text("Try again later"),
                dismissButton: .default(Text("Continue")) {
                    viewModel.errorOccurred = false
                }
            )
        }
        .ignoresSafeArea(edges: [.bottom, .horizontal])
        .background(colorScheme == .dark ? AppColors.backColorDark : AppColors.backColorLight)
    }
}

