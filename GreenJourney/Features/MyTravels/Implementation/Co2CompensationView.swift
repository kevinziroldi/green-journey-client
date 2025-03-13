import SwiftUI

struct Co2CompensationView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @ObservedObject var viewModel: MyTravelsViewModel
    var travelDetails: TravelDetails
    
    @Binding var infoTapped: Bool
    @Binding var showAlertCompensation: Bool
    
    @Binding var plantedTrees: Int
    @Binding var totalTrees: Int
    @Binding var progress: Float64
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(uiColor: .systemBackground))
                .strokeBorder(
                    LinearGradient(gradient: Gradient(colors: [.blue, .cyan, .mint, .green]),
                                   startPoint: .topTrailing, endPoint: .bottomLeading), lineWidth: 6)
                //.shadow(color: .green.opacity(0.3), radius: 5, x: 0, y: 3)
            
            ZStack {
                // title and info button
                CompensationTitleView(infoTapped: $infoTapped)
                
                CompensationButtonsView(viewModel: viewModel, travelDetails: travelDetails, showAlertCompensation: $showAlertCompensation, plantedTrees: $plantedTrees, totalTrees: $totalTrees, progress: $progress)
                    .padding(EdgeInsets(top: 15, leading: 0, bottom: 5, trailing: 20))
            }
        }
        .padding(EdgeInsets(top: 5, leading: 15, bottom: 5, trailing: 15))
    }
}

private struct CompensationTitleView: View {
    @Binding var infoTapped: Bool
    
    var body: some View {
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
                        .font(.title3)
                }
                .padding(.trailing)
                .accessibilityIdentifier("infoButton")
                
            }
            Spacer()
        }
    }
}

private struct CompensationButtonsView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @ObservedObject var viewModel: MyTravelsViewModel
    var travelDetails: TravelDetails
    @Binding var showAlertCompensation: Bool
    @Binding var plantedTrees: Int
    @Binding var totalTrees: Int
    @Binding var progress: Float64
    
    var body: some View {
        VStack {
            if (travelDetails.computeCo2Emitted() > 0.0 && travelDetails.travel.CO2Compensated < travelDetails.computeCo2Emitted()) {
                if horizontalSizeClass == .compact {
                    // iOS
                    
                    HStack {
                        VStack(spacing: 0) {
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
                                            .foregroundStyle(plantedTrees == totalTrees ? .secondary : AppColors.mainColor)
                                        
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
                                            .foregroundStyle(plantedTrees==viewModel.getPlantedTrees(travelDetails) ? .secondary : AppColors.mainColor)
                                    }
                                    .disabled(plantedTrees==viewModel.getPlantedTrees(travelDetails))
                                    .accessibilityIdentifier("minusButton")
                                }
                                
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
                            
                            CompensateButtonView(viewModel: viewModel, travelDetails: travelDetails, showAlertCompensation: $showAlertCompensation, plantedTrees: $plantedTrees, totalTrees: $totalTrees, progress: $progress)
                            
                        }
                        .padding(.leading, 15)
                        .padding(.vertical)
                        
                        VStack {
                            SemicircleCo2ChartView(progress: progress, height: 120, width: 140, lineWidth: 10)
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
                } else {
                    // iPadOS
                    
                    HStack {
                        VStack {
                            HStack {
                                ZStack {
                                    Circle()
                                        .fill(.red.opacity(0.2))
                                        .frame(width: 50, height: 50)
                                    
                                    Image(systemName: "carbon.dioxide.cloud")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 35, height: 35)
                                        .foregroundColor(.red)
                                }
                                                                
                                Text("Co2 emitted: ")
                                    .font(.system(size: 20).bold())
                                    .foregroundColor(.red.opacity(0.8))
                                    .padding(.leading, 5)
                                Text(String(format: "%.0f", travelDetails.computeCo2Emitted()) + " Kg")
                                    .font(.system(size: 22).bold())
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
                                        .frame(width: 50, height: 50)
                                    
                                    Image(systemName: "leaf")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 35, height: 35)
                                        .foregroundColor(.green)
                                }
                                
                                Text("Co2 compensated: ")
                                    .font(.system(size: 20).bold())
                                    .foregroundColor(.green.opacity(0.8))
                                    .padding(.leading, 5)
                                Text(String(format: "%.0f", travelDetails.travel.CO2Compensated) + " Kg")
                                    .font(.system(size: 20).bold())
                                    .bold()
                                    .foregroundColor(.green.opacity(0.8))
                                
                                Spacer()
                            }
                            .padding(EdgeInsets(top: 5, leading: 15, bottom: 10, trailing: 15))
                        }
                        .fixedSize()
                        
                        Spacer()
                        
                        VStack(spacing: 0) {
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
                            
                            
                            HStack {
                                Button(action: {
                                    if plantedTrees > 0 {
                                        plantedTrees -= 1
                                        viewModel.compensatedPrice -= 2
                                    }
                                }) {
                                    Image(systemName: "minus.circle")
                                        .font(.system(size: 26))
                                        .fontWeight(.light)
                                        .foregroundStyle(plantedTrees==viewModel.getPlantedTrees(travelDetails) ? .secondary : AppColors.mainColor)
                                }
                                .disabled(plantedTrees==viewModel.getPlantedTrees(travelDetails))
                                .accessibilityIdentifier("minusButton")
                                
                                Button(action: {
                                    if plantedTrees < totalTrees {
                                        plantedTrees += 1
                                        viewModel.compensatedPrice += 2
                                    }
                                }) {
                                    Image(systemName: "plus.circle")
                                        .font(.system(size: 26))
                                        .fontWeight(.light)
                                        .foregroundStyle(plantedTrees == totalTrees ? .secondary : AppColors.mainColor)
                                    
                                }
                                .disabled(plantedTrees == totalTrees)
                                .accessibilityIdentifier("plusButton")
                            }
                            
                            Text("Price: \(viewModel.compensatedPrice) €")
                                .padding()
                                .font(.system(size: 20))
                            
                            CompensateButtonView(viewModel: viewModel, travelDetails: travelDetails, showAlertCompensation: $showAlertCompensation, plantedTrees: $plantedTrees, totalTrees: $totalTrees, progress: $progress)
                            
                        }
                        .padding(.leading, 15)
                        .padding(.vertical)
                        
                        Spacer()
                        
                        VStack {
                            SemicircleCo2ChartView(progress: progress, height: 120, width: 140, lineWidth: 10)
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
                    .padding(.horizontal, 20)
                }
            } else {
                VStack {
                    HStack (spacing: 0){
                        Text("You planted: \(plantedTrees)")
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
    }
}

private struct CompensateButtonView: View {
    @ObservedObject var viewModel: MyTravelsViewModel
    var travelDetails: TravelDetails
    @Binding var showAlertCompensation: Bool
    @Binding var plantedTrees: Int
    @Binding var totalTrees: Int
    @Binding var progress: Float64
    
    var body: some View {
        Button(action: {
            showAlertCompensation = true
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(plantedTrees==viewModel.getPlantedTrees(travelDetails) ? Color.secondary.opacity(0.6) : AppColors.mainColor)
                    .stroke(plantedTrees==viewModel.getPlantedTrees(travelDetails) ? Color.secondary : AppColors.mainColor, lineWidth: 2)
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
                message: Text("You cannot undo this action"),
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
}
