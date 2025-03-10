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
                                Co2CompensationView(viewModel: viewModel, travelDetails: travelDetails, infoTapped: $infoTapped, showAlertCompensation: $showAlertCompensation, plantedTrees: $plantedTrees, totalTrees: $totalTrees, progress: $progress)
                            } else {
                                // recap full width
                                Co2RecapView(halfWidth: false, co2Emitted: travelDetails.computeCo2Emitted(), numTrees: viewModel.getNumTrees(travelDetails), distance: travelDetails.computeTotalDistance())
                                    .padding()
                                    .accessibilityElement(children: .contain)
                                    .overlay(Color.clear.accessibilityIdentifier("emissionsRecapFutureTravel"))
                            }
                            
                            // travel recap
                            TravelRecapView(distance: travelDetails.computeTotalDistance(), duration: travelDetails.computeTotalDuration(), price: travelDetails.computeTotalPrice(), greenPrice: travelDetails.computeGreenPrice())
                                .padding(.horizontal)
                                .accessibilityElement(children: .contain)
                                .overlay(Color.clear.accessibilityIdentifier("travelRecap"))
                                .padding(.vertical)
                            
                        } else {
                            // iPadOS
                            
                            if travelDetails.travel.confirmed {
                                // travel compensation
                                Co2CompensationView(viewModel: viewModel, travelDetails: travelDetails, infoTapped: $infoTapped, showAlertCompensation: $showAlertCompensation, plantedTrees: $plantedTrees, totalTrees: $totalTrees, progress: $progress)
                                
                                // travel recap full width
                                TravelRecapView(distance: travelDetails.computeTotalDistance(), duration: travelDetails.computeTotalDuration(), price: travelDetails.computeTotalPrice(), greenPrice: travelDetails.computeGreenPrice())
                                    .padding(.horizontal)
                                    .accessibilityElement(children: .contain)
                                    .overlay(Color.clear.accessibilityIdentifier("travelRecap"))
                                    .padding(.vertical)
                            } else {
                                HStack(alignment: .top) {
                                    // travel recap half width
                                    TravelRecapView(distance: travelDetails.computeTotalDistance(), duration: travelDetails.computeTotalDuration(), price: travelDetails.computeTotalPrice(), greenPrice: travelDetails.computeGreenPrice())
                                        .padding(.horizontal)
                                        .accessibilityElement(children: .contain)
                                        .overlay(Color.clear.accessibilityIdentifier("travelRecap"))
                                        .padding(.vertical)
                                    
                                    // recap half width
                                    VStack {
                                        Co2RecapView(halfWidth: true, co2Emitted: travelDetails.computeCo2Emitted(), numTrees: viewModel.getNumTrees(travelDetails), distance: travelDetails.computeTotalDistance())
                                            .padding()
                                            .accessibilityElement(children: .contain)
                                            .overlay(Color.clear.accessibilityIdentifier("emissionsRecapFutureTravel"))
                                    }
                                    .frame(maxHeight: .infinity, alignment: .top)
                                }
                            }
                        }
                        
                        if travelDetails.travel.confirmed {
                            // if the user hasn't left a review yet
                            let city = travelDetails.getDestinationSegment()?.destinationCity
                            let country = travelDetails.getDestinationSegment()?.destinationCountry
                            InsertReviewButtonView(viewModel: reviewViewModel, reviewTapped: $reviewTapped, city: city, country: country)
                                .accessibilityIdentifier("reviewButton")
                        }
                        
                        SegmentsDetailsView(travelDetails: travelDetails)
                        
                        // delete button
                        Button(action: {
                            showAlertDelete = true
                            viewModel.selectedTravel = travelDetails
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.red.opacity(0.3))
                                HStack {
                                    Image(systemName: "trash")
                                        .font(.headline)
                                        .foregroundStyle(.red)
                                    Text("Delete travel")
                                        .foregroundStyle(.red)
                                        .font(.headline)
                                }
                                .padding()
                            }
                            .padding(.vertical, 20)
                            .fixedSize()
                        }
                        .alert(isPresented: $showAlertDelete) {
                            Alert(
                                title: Text("Delete this travel?"),
                                message: Text("You cannot undo this action"),
                                primaryButton: .cancel(Text("Cancel")) {},
                                secondaryButton: .destructive(Text("Delete")) {
                                    //delete travel
                                    Task {
                                        await viewModel.deleteTravel()
                                        navigationPath.removeLast()
                                    }
                                }
                            )
                        }
                        .accessibilityIdentifier("trashButton")
                    }
                    .padding(10)
                    
                    Spacer()
                }
            }
            .sheet(isPresented: $reviewTapped) {
                InsertReviewView(isPresented: $reviewTapped, viewModel: reviewViewModel)
                    .presentationDetents([.height(680)])
                    .presentationCornerRadius(30)
            }
            .sheet(isPresented: $infoTapped) {
                InfoCompensationView(isPresented: $infoTapped)
                    .presentationDetents([.fraction(0.75)])
                    .presentationCornerRadius(30)
            }
            .ignoresSafeArea(edges: [.bottom, .horizontal])
            .background(colorScheme == .dark ? Color(red: 10/255, green: 10/255, blue: 10/255) : Color(red: 245/255, green: 245/255, blue: 245/255))
            .onAppear() {
                reviewViewModel.userReview = travelDetails.travel.userReview
                if (travelDetails.computeCo2Emitted() >= 0.0) {
                    if (travelDetails.travel.CO2Compensated >= travelDetails.computeCo2Emitted()) {
                        progress = 1.0
                    }
                    else {
                        progress = travelDetails.travel.CO2Compensated / travelDetails.computeCo2Emitted()
                    }
                    totalTrees = viewModel.getNumTrees(travelDetails)
                    plantedTrees = viewModel.getPlantedTrees(travelDetails)
                    viewModel.compensatedPrice = 0
                }
            }
        }
    }
}

struct InfoCompensationView: View {
    @Binding var isPresented: Bool
    var body: some View {
        
        HStack {
            Spacer()
            Button(action: {
                isPresented = false
            }) {
                Text("Done")
                    .fontWeight(.bold)
            }
            .padding(.horizontal, 30)
        }
        .padding(.top)
        ScrollView {
            VStack {
                Text("Travel Sustainably")
                    .font(.title)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .scaledToFit()
                    .lineLimit(1)
                    .padding(.bottom, 5)
                
                Text("Traveling has an environmental impact, but you can take action to reduce it. Every trip you take produces carbon emissions, contributing to climate change. By offsetting your Co2 footprint, you help balance these emissions and make your journeys more sustainable.")
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("How We Offset Carbon")
                    .font(.title)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .scaledToFit()
                    .lineLimit(1)
                    .padding(.top, 30)
                    .padding(.bottom, 5)
                
                Text("""
                We make it easy for you to compensate for your travel impact. 
                Our approach is simple: we plant trees! Each tree absorbs an estimated 75 kg of Co2 over its lifetime, making a real difference for the planet. 
                And the best part? 
                Planting a tree costs only €2, making carbon offsetting both affordable and effective.
                Join us in making travel greener
                """)
                .frame(maxWidth: .infinity, alignment: .leading)
                Text("Small actions lead to big changes!")
                    .font(.headline)
                    .padding(.top)
            }
            .padding(.horizontal)
        }
    }
}

struct SegmentsDetailsView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    var travelDetails: TravelDetails
    
    var body: some View {
        if horizontalSizeClass == .compact {
            // iOS
            
            VStack{
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
                HStack(alignment: .top) {
                    if !travelDetails.isOneway() {
                        Spacer()
                    }
                    
                    VStack(alignment: .leading) {
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
                            .fixedSize(horizontal: false, vertical: true)
                            .accessibilityElement(children: .contain)
                            .overlay(Color.clear.accessibilityIdentifier("outwardSegmentsView"))
                    }
                    .frame(maxWidth: 400)
                    
                    Spacer()
                    
                    if !travelDetails.isOneway() {
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Return")
                                    .font(.title)
                                    .fontWeight(.semibold)
                                    .accessibilityIdentifier("returnTitle")
                                    .padding(.horizontal, 15)
                                Spacer()
                            }
                            .padding(.top)
                            
                            VStack {
                                SegmentsView(segments: travelDetails.getReturnSegments())
                                    .fixedSize(horizontal: false, vertical: true)
                                    .accessibilityElement(children: .contain)
                                    .overlay(Color.clear.accessibilityIdentifier("returnSegmentsView"))
                            }
                        }
                        .frame(maxWidth: 400)
                        
                        Spacer()
                    }
                }
            }
        }
    }
}
