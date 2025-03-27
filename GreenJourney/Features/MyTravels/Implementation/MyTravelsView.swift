import SwiftData
import SwiftUI

struct MyTravelsView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @StateObject var viewModel: MyTravelsViewModel
    @Environment(\.modelContext) private var modelContext
    private var serverService: ServerServiceProtocol
    private var firebaseAuthService: FirebaseAuthServiceProtocol
    
    @State private var selectedSortOption: SortOption = .departureDate
    @State private var showSortOptions = false
    
    @State private var showAlert: Bool = false
    @State private var showConfirm: Bool = false
    
    @Binding var navigationPath: NavigationPath
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    init(modelContext: ModelContext,navigationPath: Binding<NavigationPath>, serverService: ServerServiceProtocol, firebaseAuthService: FirebaseAuthServiceProtocol) {
        _viewModel = StateObject(wrappedValue: MyTravelsViewModel(modelContext: modelContext, serverService: serverService))
        _navigationPath = navigationPath
        self.serverService = serverService
        self.firebaseAuthService = firebaseAuthService
    }
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    HStack {
                        Text("My Travels")
                            .font(.system(size: 32).bold())
                            .padding()
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .accessibilityIdentifier("myTravelsTitle")
                        
                        Spacer()
                        
                        if horizontalSizeClass == .compact {
                            UserPreferencesButtonView(navigationPath: $navigationPath, serverService: serverService, firebaseAuthService: firebaseAuthService)
                        }
                    }
                    .padding(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
                    
                    Picker("", selection: $viewModel.showCompleted) {
                        Text("Completed").tag(true)
                        Text("Scheduled").tag(false)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    .frame(maxWidth: 400) // set a max width to control the size
                    .accessibilityIdentifier("travelCompletedControl")
                    
                    HStack {
                        Spacer()
                        Button(action: {
                            showSortOptions.toggle()
                        }) {
                            Text("Order by")
                        }
                        .padding(.trailing, 20)
                        .actionSheet(isPresented: $showSortOptions) {
                            ActionSheet(title: Text("Sort by"), buttons: [
                                .default(Text("Departure date")) {viewModel.sortOption = .departureDate},
                                .default(Text("CO\u{2082} emitted")) {viewModel.sortOption = .co2Emitted},
                                .default(Text("CO\u{2082} compensation rate")) {viewModel.sortOption = .co2CompensationRate},
                                .default(Text("Price")) {viewModel.sortOption = .price},
                                .cancel()
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
                            }
                            else {
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
                        VStack{
                            ForEach(viewModel.filteredTravelDetailsList, id: \.id) { travelDetails in
                                HStack (spacing: 10) {
                                    Button(action: {
                                        viewModel.selectedTravel = travelDetails
                                        // selectedTravel is set synchronously
                                        navigationPath.append(NavigationDestination.TravelDetailsView(viewModel))
                                    }) {
                                        TravelCardView(travelDetails: travelDetails)
                                    }
                                    .accessibilityIdentifier("travelCardButton_\(travelDetails.travel.travelID ?? 1)")
                                    
                                    if viewModel.showCompleted && !travelDetails.travel.confirmed {
                                        VStack {
                                            
                                            Button(action: {
                                                showConfirm = true
                                                viewModel.selectedTravel = travelDetails
                                            }) {
                                                Image(systemName: "checkmark.circle")
                                                    .font(.largeTitle)
                                                    .scaleEffect(1.2)
                                                    .fontWeight(.light)
                                                    .foregroundStyle(.green)
                                            }
                                            .padding(.vertical, 5)
                                            .alert(isPresented: $showConfirm) {
                                                Alert(
                                                    title: Text("Have you done this travel?"),
                                                    primaryButton: .cancel(Text("Cancel")) {},
                                                    secondaryButton: .default(Text("Confirm")) {
                                                        //confirm travel
                                                        Task {
                                                            await viewModel.confirmTravel()
                                                        }
                                                    }
                                                )
                                            }
                                            .accessibilityIdentifier("confirmTravelButton_\(travelDetails.travel.travelID ?? 1)")
                                            
                                            Button(action: {
                                                showAlert = true
                                                viewModel.selectedTravel = travelDetails
                                            }) {
                                                Image(systemName: "trash.circle")
                                                    .font(.largeTitle)
                                                    .scaleEffect(1.2)
                                                    .fontWeight(.light)
                                                    .foregroundStyle(.red)
                                            }
                                            .padding(.vertical, 5)
                                            .alert(isPresented: $showAlert) {
                                                Alert(
                                                    title: Text("Delete this travel?"),
                                                    message: Text("You cannot undo this action"),
                                                    primaryButton: .cancel(Text("Cancel")) {},
                                                    secondaryButton: .destructive(Text("Delete")) {
                                                        //delete travel
                                                        Task {
                                                            await viewModel.deleteTravel()
                                                        }
                                                    }
                                                )
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
            .scrollClipDisabled(true)
            .clipShape(Rectangle())
            .navigationTitle("Titolo Schermata")
            .background(colorScheme == .dark ? AppColors.backColorDark : AppColors.backColorLight)
            .onAppear {
                viewModel.showRequestedTravels()
                if viewModel.filteredTravelDetailsList.isEmpty {
                    // retry
                    viewModel.showRequestedTravels()
                }
                // else empty page
            }
        }
    }
}
