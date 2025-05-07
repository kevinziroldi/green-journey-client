import SwiftUI
import SwiftData

struct TravelDetailsView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @ObservedObject var viewModel: MyTravelsViewModel
    @StateObject var reviewViewModel: CitiesReviewsViewModel
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @Binding var navigationPath: NavigationPath
    @State var reviewTapped: Bool = false
    @State var infoTapped: Bool = false
    @State var progress: Float64 = 0
    @State var showAlertDelete = false
    @State var showAlertCompensation = false
    @State var plantedTrees = 0
    @State var totalTrees = 0
    @State var isPresenting: Bool = false
    
    init(viewModel: MyTravelsViewModel ,modelContext: ModelContext, navigationPath: Binding<NavigationPath>, serverService: ServerServiceProtocol, firebaseAuthService: FirebaseAuthServiceProtocol) {
        self.viewModel = viewModel
        _reviewViewModel = StateObject(wrappedValue: CitiesReviewsViewModel(modelContext: modelContext, serverService: serverService))
        _navigationPath = navigationPath
    }
    
    var body : some View {
        if let travelDetails = viewModel.selectedTravel {
            VStack {
                ScrollView {
                    VStack {
                        HeaderView(from: travelDetails.getDepartureSegment()?.departureCity ?? "", to: travelDetails.getDestinationSegment()?.destinationCity ?? "", date: travelDetails.segments.first?.dateTime, dateArrival: travelDetails.segments.last?.getArrivalDateTime())
                            .accessibilityElement(children: .contain)
                            .overlay(Color.clear.accessibilityIdentifier("headerView"))
                        
                        // horizontal line
                        Rectangle()
                            .frame(height: 1)
                            .foregroundStyle(.gray)
                        
                        if horizontalSizeClass == .compact {
                            // iOS
                            
                            if travelDetails.travel.confirmed {
                                // travel compensation
                                CO2CompensationView(viewModel: viewModel, infoTapped: $infoTapped, showAlertCompensation: $showAlertCompensation, plantedTrees: $plantedTrees)
                            } else {
                                // recap full width
                                Co2RecapView(halfWidth: false, co2Emitted: travelDetails.computeCo2Emitted(), numTrees: viewModel.getNumTrees(), distance: travelDetails.computeTotalDistance())
                                    .padding()
                                    .accessibilityElement(children: .contain)
                                    .overlay(Color.clear.accessibilityIdentifier("emissionsRecapFutureTravel"))
                            }
                            
                            // travel recap
                            TravelRecapView(singleColumn: true, distance: travelDetails.computeTotalDistance(), duration: travelDetails.computeTotalDuration(), price: travelDetails.computeTotalPrice(), greenPrice: travelDetails.computeGreenPrice())
                                .padding(.horizontal)
                                .accessibilityElement(children: .contain)
                                .overlay(Color.clear.accessibilityIdentifier("travelRecap"))
                                .padding(.vertical)
                            
                        } else {
                            // iPadOS
                            
                            VStack {
                                if travelDetails.travel.confirmed {
                                    // travel compensation
                                    CO2CompensationView(viewModel: viewModel, infoTapped: $infoTapped, showAlertCompensation: $showAlertCompensation, plantedTrees: $plantedTrees)
                                    
                                    // travel recap two columns
                                    TravelRecapView(singleColumn: false, distance: travelDetails.computeTotalDistance(), duration: travelDetails.computeTotalDuration(), price: travelDetails.computeTotalPrice(), greenPrice: travelDetails.computeGreenPrice())
                                        .padding(.horizontal)
                                        .accessibilityElement(children: .contain)
                                        .overlay(Color.clear.accessibilityIdentifier("travelRecap"))
                                        .padding(.vertical)
                                } else {
                                    HStack(alignment: .top) {
                                        // travel recap single column
                                        TravelRecapView(singleColumn: true, distance: travelDetails.computeTotalDistance(), duration: travelDetails.computeTotalDuration(), price: travelDetails.computeTotalPrice(), greenPrice: travelDetails.computeGreenPrice())
                                            .padding()
                                            .accessibilityElement(children: .contain)
                                            .overlay(Color.clear.accessibilityIdentifier("travelRecap"))
                                        
                                        
                                        // recap half width
                                        VStack {
                                            Co2RecapView(halfWidth: true, co2Emitted: travelDetails.computeCo2Emitted(), numTrees: viewModel.getNumTrees(), distance: travelDetails.computeTotalDistance())
                                                .padding()
                                                .accessibilityElement(children: .contain)
                                                .overlay(Color.clear.accessibilityIdentifier("emissionsRecapFutureTravel"))
                                        }
                                        .frame(maxHeight: .infinity, alignment: .top)
                                    }
                                }
                            }
                            .frame(maxWidth: 800)
                        }
                        
                        
                        if travelDetails.travel.confirmed {
                            // if the user hasn't left a review yet
                            let city = travelDetails.getDestinationSegment()?.destinationCity
                            let country = travelDetails.getDestinationSegment()?.destinationCountry
                            InsertReviewButtonView(viewModel: reviewViewModel, reviewTapped: $reviewTapped, city: city, country: country, isPresenting: $isPresenting)
                                .accessibilityIdentifier("reviewButton")
                        }
                        
                        SegmentsDetailsView(travelDetails: travelDetails)
                            .frame(maxWidth: 800)
                            .padding(.leading)
                        
                        // delete button
                        Button(action: {
                            showAlertDelete = true
                            viewModel.selectedTravel = travelDetails
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.red.opacity(0.9))
                                HStack {
                                    Text("Delete travel")
                                        .foregroundStyle(.white)
                                        .font(.headline)
                                        .padding(10)
                                }
                            }
                            .fixedSize()
                        }
                        .padding(.vertical, 20)
                        .confirmationDialog("Delete this travel?", isPresented: $showAlertDelete, titleVisibility: .visible) {
                            Button("Delete", role: .destructive) {
                                Task {
                                    await viewModel.deleteTravel()
                                    if !viewModel.errorOccurred {
                                        navigationPath.removeLast()
                                    }
                                }
                            }
                            .accessibilityIdentifier("confirmDeleteButton")
                            
                            Button("Cancel", role: .cancel) {}
                                .accessibilityIdentifier("cancelDeleteButton")
                            
                        } message: {
                            Text("You cannot undo this action")
                        }
                        .accessibilityIdentifier("trashButton")
                    }
                    .padding(10)
                    
                    Spacer()
                }
            }
            .alert(isPresented: $viewModel.errorOccurred) {
                Alert(
                    title: Text("Something went wrong 😞"),
                    message: Text("Try again later"),
                    dismissButton: .default(Text("Continue")) {viewModel.errorOccurred = false}
                )
            }
            .sheet(isPresented: $reviewTapped, onDismiss: {isPresenting = false}) {
                InsertReviewView(isPresented: $reviewTapped, viewModel: reviewViewModel, isPresenting: $isPresenting)
                    .presentationDetents([.height(680)])
                    .presentationCornerRadius(15)
            }
            .sheet(isPresented: $infoTapped) {
                InfoCompensationView(isPresented: $infoTapped)
                    .presentationDetents([.fraction(0.75)])
                    .presentationCornerRadius(15)
                    .overlay(Color.clear.accessibilityIdentifier("infoCompensationView"))
            }
            .ignoresSafeArea(edges: [.bottom, .horizontal])
            .background(colorScheme == .dark ? AppColors.backColorDark : AppColors.backColorLight)
            .onAppear() {
                isPresenting = false
                reviewViewModel.userReview = travelDetails.travel.userReview
                if travelDetails.computeCo2Emitted() >= 0.0 {
                    if travelDetails.travel.CO2Compensated >= travelDetails.computeCo2Emitted() {
                        progress = 1.0
                    } else {
                        progress = travelDetails.travel.CO2Compensated / travelDetails.computeCo2Emitted()
                    }
                    totalTrees = viewModel.getNumTrees()
                    plantedTrees = viewModel.getPlantedTrees()
                    viewModel.compensatedPrice = 0
                }
            }
        }
    }
}

private struct SegmentsDetailsView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    var travelDetails: TravelDetails
    
    var body: some View {
        if horizontalSizeClass == .compact {
            // iOS
            
            VStack {
                HStack {
                    Text(travelDetails.isOneway() ? "Segments" : "Outward")
                        .font(.title)
                        .fontWeight(.semibold)
                        .accessibilityIdentifier("segmentsTitle")
                        .padding(.horizontal, 15)
                    Spacer()
                }
                .padding(.top)
                
                SegmentsView(segments: travelDetails.getOutwardSegments())
                    .accessibilityElement(children: .contain)
                    .overlay(Color.clear.accessibilityIdentifier("outwardSegmentsView"))
                
                if !travelDetails.isOneway() {
                    HStack {
                        Text("Return")
                            .font(.title)
                            .fontWeight(.semibold)
                            .accessibilityIdentifier("returnTitle")
                        Spacer()
                    }
                    .padding()
                    
                    SegmentsView(segments: travelDetails.getReturnSegments())
                        .accessibilityElement(children: .contain)
                        .overlay(Color.clear.accessibilityIdentifier("returnSegmentsView"))
                }
            }
        } else {
            // iPadOS
            
            VStack {
                if travelDetails.isOneway() {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading) {
                            HStack {
                                Text(travelDetails.isOneway() ? "Segments" : "Outward")
                                    .font(.title)
                                    .fontWeight(.semibold)
                                    .accessibilityIdentifier("segmentsTitle")
                                Spacer()
                            }
                            .fixedSize()
                            .padding(.top)
                            
                            SegmentsView(segments: travelDetails.getOutwardSegments())
                                .fixedSize(horizontal: false, vertical: true)
                                .accessibilityElement(children: .contain)
                                .overlay(Color.clear.accessibilityIdentifier("outwardSegmentsView"))
                        }
                        .frame(maxWidth: 370)
                        
                        Spacer()
                    }
                    .padding(.leading, 10)
                } else {
                    HStack(alignment: .top) {
                        Spacer()
                        
                        VStack(alignment: .leading) {
                            HStack {
                                Text(travelDetails.isOneway() ? "Segments" : "Outward")
                                    .font(.title)
                                    .fontWeight(.semibold)
                                    .accessibilityIdentifier("segmentsTitle")
                                Spacer()
                            }
                            .fixedSize()
                            .padding(.top)
                            
                            SegmentsView(segments: travelDetails.getOutwardSegments())
                                .fixedSize(horizontal: false, vertical: true)
                                .accessibilityElement(children: .contain)
                                .overlay(Color.clear.accessibilityIdentifier("outwardSegmentsView"))
                        }.frame(maxWidth: 370)
                        
                        Spacer()
                        
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Return")
                                    .font(.title)
                                    .fontWeight(.semibold)
                                    .accessibilityIdentifier("returnTitle")
                                Spacer()
                            }
                            .fixedSize()
                            .padding(.top)
                            
                            VStack {
                                SegmentsView(segments: travelDetails.getReturnSegments())
                                    .fixedSize(horizontal: false, vertical: true)
                                    .accessibilityElement(children: .contain)
                                    .overlay(Color.clear.accessibilityIdentifier("returnSegmentsView"))
                            }
                        }
                        .frame(maxWidth: 370)
                    }
                    .padding(.leading, -20)
                }
            }
        }
    }
}
