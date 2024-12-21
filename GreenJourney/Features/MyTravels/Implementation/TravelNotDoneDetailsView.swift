import SwiftUI

struct TravelNotDoneDetailsView: View {
    @ObservedObject var viewModel: MyTravelsViewModel
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @Binding var navigationPath: NavigationPath
    @State var compensationTapped: Bool = false
    @State var infoTapped: Bool = false
    @State var progress: Float64 = 0
    @State var showAlert = false
    @State var plantedTrees = 0
    @State var totalTrees = 0
    
    var body : some View {
        if let travelDetails = viewModel.selectedTravel {
            
            ZStack {
                VStack (spacing:0) {
                    HeaderView(from: travelDetails.getDepartureSegment()?.departureCity ?? "", to: travelDetails.getDestinationSegment()?.destinationCity ?? "", date: travelDetails.segments.first?.dateTime, dateArrival: travelDetails.segments.last?.getArrivalDateTime())
                    
                    Rectangle()
                        .frame(height: 1)
                        .foregroundStyle(.gray)
                    ScrollView {
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color(uiColor: .systemBackground))
                                .shadow(color: Color(hue: 0.309, saturation: 1.0, brightness: 0.665).opacity(0.3), radius: 5, x: 0, y: 3)
                            VStack (spacing:0){
                                Text("Co2")
                                    .font(.title)
                                    .foregroundStyle(Color(hue: 0.309, saturation: 1.0, brightness: 0.665).opacity(0.8))
                                    .padding(EdgeInsets(top: 15, leading: 15, bottom: 0, trailing: 0))
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                HStack {
                                    Text("Emission: " + String(format: "%.1f", travelDetails.computeCo2Emitted()) + " Kg")
                                    Spacer()
                                    Text("#10")
                                    Image(systemName: "tree")
                                }
                                .font(.title2)
                                .fontWeight(.semibold)
                                .padding()
                                .foregroundStyle(Color(hue: 0.309, saturation: 1.0, brightness: 0.665).opacity(1))
                            }
                        }
                        .padding(EdgeInsets(top: 10, leading: 15, bottom: 5, trailing: 15))
                        
                        TravelRecapView(travelDetails: travelDetails)
                            .padding(EdgeInsets(top: 10, leading: 15, bottom: 5, trailing: 15))
                        
                        HStack {
                            Text(travelDetails.isOneway() ? "Segments" : "Outward")
                                .font(.title)
                                .fontWeight(.semibold)
                            Spacer()
                            
                            Button(action: {
                                showAlert = true
                            }) {
                                Image(systemName: "trash.circle")
                                    .font(.largeTitle)
                                    .scaleEffect(1.2)
                                    .fontWeight(.light)
                                    .foregroundStyle(.red)
                            }
                            .alert(isPresented: $showAlert) {
                                Alert(
                                    title: Text("Delete this travel?"),
                                    message: Text("you cannot undo this action"),
                                    primaryButton: .cancel(Text("Cancel")) {},
                                    secondaryButton: .destructive(Text("Delete")) {
                                        //delete travel
                                        viewModel.deleteTravel(travelToDelete: travelDetails.travel)
                                        navigationPath.removeLast()
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 15)
                        
                        SegmentsView(segments: travelDetails.getOutwardSegments())
                        
                        if !travelDetails.isOneway() {
                            HStack {
                                Text("Return")
                                    .font(.title)
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                            .padding()
                            SegmentsView(segments: travelDetails.getReturnSegments())
                        }
                    }
                    .padding(10)
                    
                    Spacer()
                }
            }
            .background(colorScheme == .dark ? Color(red: 10/255, green: 10/255, blue: 10/255) : Color(red: 245/255, green: 245/255, blue: 245/255))
        }
    }
}


struct TravelRecapView: View {
    let travelDetails: TravelDetails
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(uiColor: .systemBackground))
                .shadow(color: .indigo.opacity(0.3), radius: 5, x: 0, y: 3)
            VStack (spacing:0){
                Text("Recap")
                    .font(.title)
                    .foregroundStyle(.indigo.opacity(0.8))
                    .padding(EdgeInsets(top: 15, leading: 15, bottom: 10, trailing: 0))
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                HStack {
                    ZStack {
                        Circle()
                            .fill(.indigo.opacity(0.2))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "road.lanes")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                            .foregroundColor(.indigo)
                    }
                    
                    
                    Text("Distance")
                        .font(.system(size: 20).bold())
                        .foregroundColor(.primary)
                        .padding(.leading, 5)
                        .frame(width: 120, alignment: .leading)
                    Text(String(format: "%.1f", travelDetails.computeTotalDistance()) + " Km")
                        .font(.system(size: 25).bold())
                        .bold()
                        .foregroundColor(.indigo.opacity(0.8))
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical, 5)
                HStack {
                    ZStack {
                        Circle()
                            .fill(.blue.opacity(0.2))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "clock")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                            .foregroundColor(.blue)
                    }
                    
                    
                    Text("Duration")
                        .font(.system(size: 20).bold())
                        .foregroundColor(.primary)
                        .padding(.leading, 5)
                        .frame(width: 120, alignment: .leading)

                    Text(travelDetails.computeTotalDuration())
                        .font(.system(size: 25).bold())
                        .bold()
                        .foregroundColor(.blue.opacity(0.8))
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical, 5)
                
                HStack {
                    ZStack {
                        Circle()
                            .fill(.red.opacity(0.2))
                            .frame(width: 40, height: 40)
                        
                        Image("price_red")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.red)
                    }
                    
                    
                    Text("Price")
                        .font(.system(size: 20).bold())
                        .foregroundColor(.primary)
                        .padding(.leading, 5)
                        .frame(width: 120, alignment: .leading)

                    Text(String(format: "%.2f", travelDetails.computeTotalPrice()) + " €")
                        .font(.system(size: 25).bold())
                        .bold()
                        .foregroundColor(.red.opacity(0.8))
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical, 5)
                HStack {
                    ZStack {
                        Circle()
                            .fill(.green.opacity(0.2))
                            .frame(width: 40, height: 40)
                        
                        Image("price_green")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.green)
                    }
                    
                    
                    Text("Green price")
                        .font(.system(size: 20).bold())
                        .foregroundColor(.primary)
                        .padding(.leading, 5)
                        .frame(width: 120, alignment: .leading)

                    Text(String(format: "%.1f", travelDetails.computeTotalDistance()) + " Km")
                        .font(.system(size: 25).bold())
                        .bold()
                        .foregroundColor(.green.opacity(0.8))
                    Spacer()
                }
                .padding(EdgeInsets(top: 5, leading: 15, bottom: 10, trailing: 15))
            }
        }
    }
}
