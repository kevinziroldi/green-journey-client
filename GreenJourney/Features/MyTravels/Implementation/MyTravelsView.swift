import SwiftData
import SwiftUI

struct MyTravelsView: View {
    
    @State var isPresenting: Bool = false
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @StateObject private var viewModel: MyTravelsViewModel
    @Environment(\.modelContext) private var modelContext
    private var serverService: ServerServiceProtocol
    private var firebaseAuthService: FirebaseAuthServiceProtocol
    
    @State private var selectedSortOption: SortOption = .departureDate
    @State private var showSortOptions = false
    
    @State private var showAlertTravelID: Int?
    @State private var showConfirmTravelID: Int?
    
    @Binding var navigationPath: NavigationPath
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    init(modelContext: ModelContext,navigationPath: Binding<NavigationPath>, serverService: ServerServiceProtocol, firebaseAuthService: FirebaseAuthServiceProtocol) {
        _viewModel = StateObject(wrappedValue: MyTravelsViewModel(modelContext: modelContext, serverService: serverService))
        _navigationPath = navigationPath
        self.serverService = serverService
        self.firebaseAuthService = firebaseAuthService
    }
    var body: some View {
        ScrollView {
            VStack {
                if horizontalSizeClass == .compact {
                    // iOS
                    
                    HStack {
                        Text("My Travels")
                            .font(.system(size: 32).bold())
                            .padding(.vertical)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .accessibilityIdentifier("myTravelsTitle")
                        
                        Spacer()

                        UserPreferencesButtonView(navigationPath: $navigationPath, isPresenting: $isPresenting)
                    }
                    .padding(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
                } else {
                    // iPadOS
                    
                    HStack {
                        Spacer()
                        Text("My Travels")
                            .font(.system(size: 32).bold())
                            .padding(.vertical)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .accessibilityIdentifier("myTravelsTitle")
                            .frame(maxWidth: 800)
                        Spacer()
                    }
                }
                
                Picker("", selection: $viewModel.showCompleted) {
                    Text("Completed").tag(true)
                    Text("Scheduled").tag(false)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                .frame(maxWidth: 400) // set a max width to control the size
                .accessibilityIdentifier("travelCompletedControl")
                .disabled(isPresenting)
                
                HStack {
                    Spacer()
                    Button(action: {
                        if !isPresenting {
                            isPresenting = true
                            showSortOptions.toggle()
                        }
                    }) {
                        Text("Order by")
                    }
                    .padding(.trailing, 20)
                    .actionSheet(isPresented: $showSortOptions) {
                        ActionSheet(title: Text("Sort by"), buttons: [
                            .default(Text("Departure date")) {viewModel.sortOption = .departureDate
                                isPresenting = false},
                            .default(Text("CO\u{2082} emitted")) {viewModel.sortOption = .co2Emitted
                                isPresenting = false},
                            .default(Text("CO\u{2082} compensation rate")) {viewModel.sortOption = .co2CompensationRate
                                isPresenting = false},
                            .default(Text("Price")) {viewModel.sortOption = .price
                                isPresenting = false},
                            .cancel({isPresenting = false})
                        ])
                    }
                    .accessibilityIdentifier("sortByButton")
                }
                .padding(.vertical, 10)
                .frame(maxWidth: 800)
                
                
                if viewModel.filteredTravelDetailsList.count == 0 {
                    VStack {
                        if colorScheme == .dark {
                            Image("noTravelsDark")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 300, height: 300)
                        } else {
                            Image("noTravelsLight")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 300, height: 300)
                        }
                        Text("You have no trips in this section yet")
                            .font(.headline)
                            .fontWeight(.light)
                    }
                    .accessibilityIdentifier("noTravelsAlert")
                }
                else {
                    VStack {
                        ForEach(viewModel.filteredTravelDetailsList, id: \.travel.travelID) { travelDetails in
                            HStack (spacing: 10) {
                                Button(action: {
                                    if !isPresenting {
                                        isPresenting = true
                                        viewModel.selectedTravel = travelDetails
                                        // selectedTravel is set synchronously
                                        navigationPath.append(NavigationDestination.TravelDetailsView(viewModel))
                                    }
                                }) {
                                    TravelCardView(travelDetails: travelDetails)
                                }
                                .accessibilityIdentifier("travelCardButton_\(travelDetails.travel.travelID ?? 1)")
                                
                                if viewModel.showCompleted && !travelDetails.travel.confirmed {
                                    VStack {
                                        
                                        Button(action: {
                                            showConfirmTravelID = travelDetails.travel.travelID
                                            viewModel.selectedTravel = travelDetails
                                        }) {
                                            Image(systemName: "checkmark.circle")
                                                .font(.largeTitle)
                                                .scaleEffect(1.2)
                                                .fontWeight(.light)
                                                .foregroundStyle(.green)
                                        }
                                        .padding(.vertical, 5)
                                        .confirmationDialog("Have you done this travel?", isPresented: Binding<Bool>(
                                            get: { showConfirmTravelID == travelDetails.travel.travelID },
                                            set: { newValue in
                                                if !newValue { showConfirmTravelID = nil }
                                            }), titleVisibility: .visible) {
                                            Button("Confirm") { Task {await viewModel.confirmTravel()} }
                                            Button("Cancel", role: .cancel) {}
                                        }
                                        .accessibilityIdentifier("confirmTravelButton_\(travelDetails.travel.travelID ?? 1)")
                                        
                                        Button(action: {
                                            showAlertTravelID = travelDetails.travel.travelID
                                            viewModel.selectedTravel = travelDetails
                                        }) {
                                            Image(systemName: "trash.circle")
                                                .font(.largeTitle)
                                                .scaleEffect(1.2)
                                                .fontWeight(.light)
                                                .foregroundStyle(.red)
                                        }
                                        .padding(.vertical, 5)
                                        .confirmationDialog("Delete this travel?", isPresented: Binding<Bool>(
                                            get: { showAlertTravelID == travelDetails.travel.travelID },
                                            set: { newValue in
                                                if !newValue { showAlertTravelID = nil }
                                            }), titleVisibility: .visible) {
                                            Button("Delete", role: .destructive) { Task {await viewModel.deleteTravel()}}
                                            Button("Cancel", role: .cancel) {}
                                        } message: {
                                            Text("You cannot undo this action")
                                        }
                                        .accessibilityIdentifier("deleteTravelButton_\(travelDetails.travel.travelID ?? 1)")
                                    }
                                }
                            }
                            .frame(maxWidth: 800)
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .padding(.bottom)
        }
        .alert(isPresented: $viewModel.errorOccurred) {
            Alert(
                title: Text("Something went wrong 😞"),
                message: Text("Try again later"),
                dismissButton: .default(Text("Continue")) {viewModel.errorOccurred = false}
            )
        }
        .refreshable {
            Task{
                await viewModel.getUserTravels()
                viewModel.showRequestedTravels()
                if viewModel.filteredTravelDetailsList.isEmpty {
                    // retry
                    viewModel.showRequestedTravels()
                }
            }
        }
        .scrollClipDisabled(true)
        .clipShape(Rectangle())
        .background(colorScheme == .dark ? AppColors.backColorDark : AppColors.backColorLight)
        .onAppear {
            isPresenting = false
            Task { await viewModel.getUserTravels() }
            viewModel.showRequestedTravels()
            if viewModel.filteredTravelDetailsList.isEmpty {
                // retry
                viewModel.showRequestedTravels()
            }
            // else empty page
        }
    }
}
