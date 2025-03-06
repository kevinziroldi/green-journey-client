import SwiftUI
import SwiftData

struct TravelDetailsView: View {
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
                        
                        Rectangle()
                            .frame(height: 1)
                            .foregroundStyle(.gray)
                        if travelDetails.travel.confirmed {
                            ZStack {
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color(uiColor: .systemBackground))
                                    .strokeBorder(
                                        LinearGradient(gradient: Gradient(colors: [.blue, .cyan, .mint, .green]),
                                                       startPoint: .topTrailing, endPoint: .bottomLeading), lineWidth: 6)
                                    .shadow(color: .green.opacity(0.3), radius: 5, x: 0, y: 3)
                                
                                ZStack {
                                    VStack {
                                        HStack {
                                            Text("Compensation")
                                                .font(.title)
                                                .foregroundStyle(.green.opacity(0.8))
                                                .padding(EdgeInsets(top: 15, leading: 15, bottom: 10, trailing: 0))
                                                .fontWeight(.semibold)
                                            Spacer()
                                            Button(action: {
                                                infoTapped = true
                                            }) {
                                                Image(systemName: "info.circle")
                                                    .foregroundStyle(.gray)
                                                    .font(.title3)
                                            }
                                            .padding(.trailing)
                                            .accessibilityIdentifier("infoButton")
                                            
                                        }
                                        Spacer()
                                    }
                                    HStack{
                                        VStack {
                                            if (travelDetails.computeCo2Emitted() > 0.0 && travelDetails.travel.CO2Compensated < travelDetails.computeCo2Emitted()) {
                                                VStack (spacing: 0){
                                                    HStack {
                                                        VStack (spacing: 10) {
                                                            Button(action: {
                                                                if plantedTrees < totalTrees {
                                                                    plantedTrees += 1
                                                                    viewModel.compensatedPrice += 2
                                                                }
                                                            }) {
                                                                Image(systemName: "plus.circle")
                                                                    .font(.system(size: 26))
                                                                    .fontWeight(.light)
                                                                    .foregroundStyle(plantedTrees == totalTrees ? .secondary : AppColors.mainGreen)
                                                                
                                                            }
                                                            .disabled(plantedTrees == totalTrees)
                                                            .accessibilityIdentifier("plusButton")
                                                            
                                                            Button(action: {
                                                                if plantedTrees > 0 {
                                                                    plantedTrees -= 1
                                                                    viewModel.compensatedPrice -= 2
                                                                }
                                                            }) {
                                                                Image(systemName: "minus.circle")
                                                                    .font(.system(size: 26))
                                                                    .fontWeight(.light)
                                                                    .foregroundStyle(plantedTrees==viewModel.getPlantedTrees(travelDetails) ? .secondary : AppColors.mainGreen)
                                                            }
                                                            .disabled(plantedTrees==viewModel.getPlantedTrees(travelDetails))
                                                            .accessibilityIdentifier("minusButton")
                                                        }
                                                        //.padding(.leading, 20)
                                                        
                                             
                                                        Spacer()
                                                        
                                                        HStack {
                                                            Text("\(plantedTrees) / \(totalTrees)")
                                                                .font(.system(size: 25))
                                                            Image(systemName: "tree")
                                                                .font(.system(size: 25))
                                                                .padding(.bottom, 5)
                                                        }
                                                        .scaledToFit()
                                                        .minimumScaleFactor(0.6)
                                                        
                                                        Spacer()
                                                    }
                                                    .padding(.trailing, 15)
                                                    
                                                    Text("Price: \(viewModel.compensatedPrice) €")
                                                        .padding()
                                                        .font(.system(size: 17))
                                                    
                                                    Button(action: {
                                                        showAlertCompensation = true
                                                    }) {
                                                        ZStack {
                                                            RoundedRectangle(cornerRadius: 10)
                                                                .fill(plantedTrees==viewModel.getPlantedTrees(travelDetails) ? Color.secondary.opacity(0.6) : AppColors.mainGreen)
                                                                .stroke(plantedTrees==viewModel.getPlantedTrees(travelDetails) ? Color.secondary : Color(red: 1/255, green: 150/255, blue: 1/255), lineWidth: 2)
                                                            HStack (spacing: 3) {
                                                                Image(systemName: "leaf")
                                                                    .font(.title3)
                                                                    .fontWeight(.semibold)
                                                                    .fontWeight(.light)
                                                                    .foregroundStyle(.white)
                                                                Text("Compensate")
                                                                    .foregroundStyle(.white)
                                                                    .fontWeight(.semibold)
                                                            }
                                                            .scaledToFit()
                                                            .minimumScaleFactor(0.6)
                                                            .padding(10)
                                                        }
                                                        .fixedSize()
                                                    }
                                                    .disabled(plantedTrees==viewModel.getPlantedTrees(travelDetails))
                                                    .padding(.bottom, 15)
                                                    
                                                    .alert(isPresented: $showAlertCompensation) {
                                                        Alert(
                                                            title: Text("Compensate \(viewModel.compensatedPrice)€ for this travel?"),
                                                            message: Text("you cannot undo this action"),
                                                            primaryButton: .cancel(Text("Cancel")) {},
                                                            secondaryButton: .default(Text("Confirm")) {
                                                                //compensate travel
                                                                Task {
                                                                    viewModel.compensatedPrice = (plantedTrees-viewModel.getPlantedTrees(travelDetails)) * 2
                                                                    await viewModel.compensateCO2()
                                                                    if (travelDetails.travel.CO2Compensated >= travelDetails.computeCo2Emitted()) {
                                                                        progress = 1.0
                                                                    }
                                                                    else {
                                                                        progress = travelDetails.travel.CO2Compensated / travelDetails.computeCo2Emitted()
                                                                    }
                                                                    totalTrees = viewModel.getNumTrees(travelDetails)
                                                                    plantedTrees = viewModel.getPlantedTrees(travelDetails)
                                                                    
                                                                }
                                                            }
                                                        )
                                                    }
                                                    .accessibilityIdentifier("compensateButton")
                                                }
                                                .padding(.leading, 15)
                                                .padding(.vertical)
                                            }
                                            else {
                                                VStack {
                                                    HStack (spacing: 0){
                                                        Text("you planted: \(plantedTrees)")
                                                            .font(.system(size: 20))
                                                        Image(systemName: "tree")
                                                            .font(.system(size: 20))
                                                            .padding(.bottom, 5)
                                                    }
                                                    .padding()
                                                    
                                                    Text("Thank you 🌍")
                                                        .font(.system(size: 18))
                                                        .fontWeight(.light)
                                                    
                                                        .padding()
                                                }
                                            }
                                        }
                                        .padding(.top, 40)
                                        .frame(maxWidth: .infinity)
                                        VStack {
                                            SemicircleCo2Chart(progress: progress, height: 120, width: 140, lineWidth: 10)
                                                .padding(.top, 25)
                                            
                                            HStack {
                                                Text(" 0 Kg       ")
                                                Text(String(format: "%.1f", travelDetails.computeCo2Emitted()) + " Kg")
                                            }
                                            .padding(.bottom, 10)
                                            .font(.headline)
                                        }
                                        .padding(.trailing, 5)
                                        
                                    }
                                    .padding(EdgeInsets(top: 15, leading: 0, bottom: 5, trailing: 20))
                                    
                                }
                            }
                            .padding(EdgeInsets(top: 5, leading: 15, bottom: 5, trailing: 15))
                        }
                        else {
                            Co2RecapView(co2Emitted: travelDetails.computeCo2Emitted(), numTrees: viewModel.getNumTrees(travelDetails), distance: travelDetails.computeTotalDistance())
                            .padding()
                            .accessibilityElement(children: .contain)
                            .overlay(Color.clear.accessibilityIdentifier("emissionsRecapFutureTravel"))
                        }
                        
                        TravelRecapView(distance: travelDetails.computeTotalDistance(), duration: travelDetails.computeTotalDuration(), price: travelDetails.computeTotalPrice(), greenPrice: travelDetails.computeGreenPrice())
                            .padding(.horizontal)
                            .accessibilityElement(children: .contain)
                            .overlay(Color.clear.accessibilityIdentifier("travelRecap"))
                            .padding(.vertical)
                        
                        if travelDetails.travel.confirmed {
                            // if the user hasn't left a review yet
                            let city = travelDetails.getDestinationSegment()?.destinationCity
                            let country = travelDetails.getDestinationSegment()?.destinationCountry
                            InsertReviewButton(viewModel: reviewViewModel, reviewTapped: $reviewTapped, city: city, country: country)
                                .accessibilityIdentifier("reviewButton")
                        }
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
                            .padding(.bottom)
                            .fixedSize()
                        }
                        .alert(isPresented: $showAlertDelete) {
                            Alert(
                                title: Text("Delete this travel?"),
                                message: Text("you cannot undo this action"),
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

            .ignoresSafeArea(edges: [.bottom, .horizontal])
            .background(colorScheme == .dark ? Color(red: 10/255, green: 10/255, blue: 10/255) : Color(red: 245/255, green: 245/255, blue: 245/255))
            .onAppear() {
                if (travelDetails.computeCo2Emitted() >= 0.0) {
                    if (travelDetails.travel.CO2Compensated >= travelDetails.computeCo2Emitted()) {
                        progress = 1.0
                    }
                    else {
                        progress = travelDetails.travel.CO2Compensated / travelDetails.computeCo2Emitted()
                    }
                    totalTrees = viewModel.getNumTrees(travelDetails)
                    plantedTrees = viewModel.getPlantedTrees(travelDetails)
                }
            }
        }
    }
}

struct InfoCompensationView: View {
    var onBack: () -> Void
    var body: some View {
        VStack {
            Text("""
                long
text
legend compensation
"""
            )
            .accessibilityIdentifier("infoText")
            
            Button("Close") {
                onBack()
            }
            .accessibilityIdentifier("infoCloseButton")
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 10)
        .frame(width: 330, height: 500)
    }
}
