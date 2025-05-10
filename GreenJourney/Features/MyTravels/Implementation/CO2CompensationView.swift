import SwiftUI

struct CO2CompensationView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    @ObservedObject var viewModel: MyTravelsViewModel
    
    @Binding var infoTapped: Bool
    @Binding var showAlertCompensation: Bool
    @Binding var plantedTrees: Int
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(colorScheme == .dark ? AppColors.blockColorDark: Color(uiColor: .systemBackground))
                .strokeBorder(
                    LinearGradient(gradient: Gradient(colors: [.blue, .cyan, .mint, .green]),
                                   startPoint: .topTrailing, endPoint: .bottomLeading), lineWidth: 6)
            
            ZStack {
                // title and info button
                CompensationTitleView(infoTapped: $infoTapped)
                
                CompensationButtonsView(viewModel: viewModel, showAlertCompensation: $showAlertCompensation, plantedTrees: $plantedTrees)
                    .padding(.trailing, 20)
                    .padding(.top)
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
                    .foregroundStyle(AppColors.green)
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
                .accessibilityIdentifier("infoCompensationButton")
                
            }
            Spacer()
        }
    }
}

private struct CompensationButtonsView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @ObservedObject var viewModel: MyTravelsViewModel
    @Binding var showAlertCompensation: Bool
    @Binding var plantedTrees: Int
    
    var body: some View {
        VStack {
            if (viewModel.getProgressSelectedTravel() < 1) {
                if horizontalSizeClass == .compact {
                    // iOS
                    
                    HStack {
                        VStack(spacing: 0) {
                            HStack {
                                Spacer()
                                HStack(alignment:.center) {
                                    Image(systemName: "tree")
                                        .font(.system(size: 20))
                                        .padding(.bottom, 5)
                                    
                                    Text("\(plantedTrees) / \(viewModel.getNumTrees())")
                                        .font(.system(size: 20))
                                        .frame(width: viewModel.getNumTrees() < 10 ? 40 : 65, alignment: .trailing)
                                }
                                Spacer()
                            }
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
                                        .foregroundStyle(plantedTrees==viewModel.getPlantedTrees() ? .secondary : AppColors.mainColor)
                                }
                                .disabled(plantedTrees==viewModel.getPlantedTrees())
                                .accessibilityIdentifier("minusButton")
                                
                                Button(action: {
                                    if plantedTrees < viewModel.getNumTrees() {
                                        plantedTrees += 1
                                        viewModel.compensatedPrice += 2
                                    }
                                }) {
                                    Image(systemName: "plus.circle")
                                        .font(.system(size: 26))
                                        .fontWeight(.light)
                                        .foregroundStyle(plantedTrees == viewModel.getNumTrees() ? .secondary : AppColors.mainColor)
                                    
                                }
                                .disabled(plantedTrees == viewModel.getNumTrees())
                                .accessibilityIdentifier("plusButton")
                            }
                            
                            Spacer()
                            
                            Text("Price: \(viewModel.compensatedPrice) €")
                                .font(.system(size: 20))
                            
                            Spacer()
                            
                            CompensateButtonView(viewModel: viewModel, showAlertCompensation: $showAlertCompensation, plantedTrees: $plantedTrees)
                        }
                        .frame(width: UIScreen.main.bounds.size.height <= 667 ? 120 : 150)
                        
                        Spacer()
                        
                        VStack {
                            GeometryReader { geometry in
                                SemicircleCo2ChartView(progress: viewModel.getProgressSelectedTravel(), height: geometry.size.height, width: geometry.size.width, lineWidth: 10)
                                    .position(x: geometry.size.width/2, y: geometry.size.height/2 - 15)
                                
                                Text(String(format: "%.1f", viewModel.getCo2CompensatedSelectedTravel()) + " Kg")
                                    .font(.headline)
                                    .position(x: geometry.size.width/2 - 50, y: geometry.size.height/2 + 60)
                                
                                Text(String(format: "%.1f", viewModel.getCo2EmittedSelectedTravel()) + " Kg")
                                    .font(.headline)
                                    .position(x: geometry.size.width/2 + 50, y: geometry.size.height/2 + 60)
                            }
                        }
                        .frame(width: UIScreen.main.bounds.size.height <= 667 ? 120 : 150, height: 160)
                    }
                    .padding()
                } else {
                    // iPadOS
                    
                    HStack {
                        Spacer()
                        VStack {
                            HStack {
                                VStack (spacing: 10){
                                    Button(action: {
                                        if plantedTrees < viewModel.getNumTrees() {
                                            plantedTrees += 1
                                            viewModel.compensatedPrice += 2
                                        }
                                    }) {
                                        Image(systemName: "plus.circle")
                                            .font(.system(size: 30))
                                            .fontWeight(.light)
                                            .foregroundStyle(plantedTrees == viewModel.getNumTrees() ? .secondary : AppColors.mainColor)
                                        
                                    }
                                    .disabled(plantedTrees == viewModel.getNumTrees())
                                    .accessibilityIdentifier("plusButton")
                                    
                                    Button(action: {
                                        if plantedTrees > 0 {
                                            plantedTrees -= 1
                                            viewModel.compensatedPrice -= 2
                                        }
                                    }) {
                                        Image(systemName: "minus.circle")
                                            .font(.system(size: 30))
                                            .fontWeight(.light)
                                            .foregroundStyle(plantedTrees==viewModel.getPlantedTrees() ? .secondary : AppColors.mainColor)
                                    }
                                    .disabled(plantedTrees==viewModel.getPlantedTrees())
                                    .accessibilityIdentifier("minusButton")
                                }
                                
                                VStack(spacing: 0) {
                                    HStack(alignment:.center) {
                                        Image(systemName: "tree")
                                            .font(.system(size: 25))
                                            .padding(.bottom, 5)
                                        
                                        Text("\(plantedTrees) / \(viewModel.getNumTrees())")
                                            .font(.system(size: 25))
                                            .frame(width: viewModel.getNumTrees() < 10 ? 60 : 80, alignment: .trailing)
                                    }
                                }
                                .padding(.horizontal)
                                
                                Text("Price: \(viewModel.compensatedPrice) €")
                                    .padding()
                                    .font(.system(size: 25))
                                    .frame(width: 150, alignment: .leading)
                            }
                            
                            CompensateButtonView(viewModel: viewModel, showAlertCompensation: $showAlertCompensation, plantedTrees: $plantedTrees)
                                .padding(.top, 30)
                            
                        }
                        .frame(maxWidth: 300)
                        .padding(.vertical)
                        
                        Spacer()
                        
                        VStack {
                            GeometryReader { geometry in
                                SemicircleCo2ChartView(progress: viewModel.getProgressSelectedTravel(), height: 140, width: 180, lineWidth: 12)
                                    .position(x: geometry.size.width/2, y: geometry.size.height/2 - 15)
                                Text(String(format: "%.1f", viewModel.getCo2CompensatedSelectedTravel()) + " Kg")
                                    .font(.system(size: 20))
                                    .fontWeight(.semibold)
                                    .position(x: geometry.size.width/2 - 70, y: geometry.size.height/2 + 80)
                                Text(String(format: "%.1f", viewModel.getCo2EmittedSelectedTravel()) + " Kg")
                                    .font(.system(size: 20))
                                    .fontWeight(.semibold)
                                    .position(x: geometry.size.width/2 + 70, y: geometry.size.height/2 + 80)
                            }
                        }
                        .frame(width: 200, height: 220)
                        Spacer()
                    }
                }
            } else {
                if horizontalSizeClass == .compact {
                    // iPhone
                    
                    VStack {
                        HStack {
                            VStack {
                                Text("You planted")
                                    .font(.system(size: 20))
                                
                                HStack (spacing: 5) {
                                    Text("\(plantedTrees)")
                                        .font(.system(size: 20))
                                    Image(systemName: "tree")
                                        .font(.system(size: 20))
                                        .padding(.bottom, 5)
                                }
                                
                                Text("Thank you 🌍")
                                    .font(.system(size: 18))
                                    .fontWeight(.light)
                            }
                            .frame(width: UIScreen.main.bounds.size.height <= 667 ? 120 : 150)
                            
                            Spacer()
                            
                            VStack {
                                GeometryReader { geometry in
                                    SemicircleCo2ChartView(progress: viewModel.getProgressSelectedTravel(), height: geometry.size.height, width: geometry.size.width, lineWidth: 10)
                                        .position(x: geometry.size.width/2, y: geometry.size.height/2 - 15)
                                    
                                    Text(String(format: "%.1f", viewModel.getCo2CompensatedSelectedTravel()) + " Kg")
                                        .font(.headline)
                                        .position(x: geometry.size.width/2 - 50, y: geometry.size.height/2 + 60)
                                    
                                    Text(String(format: "%.1f", viewModel.getCo2EmittedSelectedTravel()) + " Kg")
                                        .font(.headline)
                                        .position(x: geometry.size.width/2 + 50, y: geometry.size.height/2 + 60)
                                }
                            }
                            .frame(width: UIScreen.main.bounds.size.height <= 667 ? 120 : 150, height: 160)
                        }
                    }
                    .padding()
                } else {
                    // iPadOS
                    
                    HStack {
                        Spacer()
                        VStack {
                            HStack (spacing: 5) {
                                Text("You planted: \(plantedTrees)")
                                    .font(.system(size: 30))
                                Image(systemName: "tree")
                                    .font(.system(size: 30))
                                    .padding(.bottom, 5)
                            }
                            .scaledToFit()
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                            .padding()
                            
                            Text("Thank you 🌍")
                                .font(.system(size: 25))
                                .fontWeight(.light)
                                .padding()
                        }
                        .frame(maxWidth: 300)
                        
                        Spacer()
                        VStack {
                            GeometryReader { geometry in
                                SemicircleCo2ChartView(progress: viewModel.getProgressSelectedTravel(), height: 140, width: 180, lineWidth: 12)
                                    .position(x: geometry.size.width/2, y: geometry.size.height/2 - 15)
                                Text(String(format: "%.1f", viewModel.getCo2CompensatedSelectedTravel()) + " Kg")
                                    .font(.system(size: 20))
                                    .fontWeight(.semibold)
                                    .position(x: geometry.size.width/2 - 70, y: geometry.size.height/2 + 80)
                                Text(String(format: "%.1f", viewModel.getCo2EmittedSelectedTravel()) + " Kg")
                                    .font(.system(size: 20))
                                    .fontWeight(.semibold)
                                    .position(x: geometry.size.width/2 + 70, y: geometry.size.height/2 + 80)
                            }
                        }
                        .frame(width: 200 ,height: 220)
                        Spacer()
                    }
                }
            }
        }
        .padding(.top, 40)
        .frame(maxWidth: .infinity)
    }
}

private struct CompensateButtonView: View {
    @ObservedObject var viewModel: MyTravelsViewModel
    @Binding var showAlertCompensation: Bool
    @Binding var plantedTrees: Int
    
    var body: some View {
        Button(action: {
            showAlertCompensation = true
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(plantedTrees==viewModel.getPlantedTrees() ? Color.secondary.opacity(0.6) : AppColors.mainColor)
                
                Text("Compensate")
                    .foregroundStyle(.white)
                    .fontWeight(.semibold)
                    .scaledToFit()
                    .minimumScaleFactor(0.6)
                    .padding(10)
            }
            .fixedSize()
        }
        .disabled(plantedTrees==viewModel.getPlantedTrees())
        .confirmationDialog("Compensate \(viewModel.compensatedPrice)€ for this travel?", isPresented: $showAlertCompensation, titleVisibility: .visible) {
            Button("Confirm") {
                Task {
                    viewModel.compensatedPrice = (plantedTrees-viewModel.getPlantedTrees()) * 2
                    await viewModel.compensateCO2()
                    if viewModel.errorOccurred {
                        viewModel.compensatedPrice = 0
                        plantedTrees = viewModel.getPlantedTrees()
                    }
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("You cannot undo this action")
        }
        .accessibilityIdentifier("compensateButton")
    }
}


