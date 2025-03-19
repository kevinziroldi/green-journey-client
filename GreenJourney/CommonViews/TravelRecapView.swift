import SwiftUI

struct TravelRecapView: View {
    let singleColumn: Bool
    
    let distance: Float64
    let duration: String
    let price: Float64
    let greenPrice: Float64
    
    @State var infoTapped = false
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(uiColor: .systemBackground))
                .shadow(color: AppColors.mainColor.opacity(0.3), radius: 5, x: 0, y: 3)
            
            if singleColumn {
                VStack(spacing:0) {
                    HStack {
                        Text("Recap")
                            .font(.title)
                            .foregroundStyle(AppColors.mainColor.opacity(0.8))
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Spacer()
                        
                        Button(action: {
                            infoTapped = true
                        }) {
                            Image(systemName: "info.circle")
                                .font(.title3)
                        }
                        .accessibilityIdentifier("infoGreenPriceButton")
                    }
                    .padding(EdgeInsets(top: 15, leading: 15, bottom: 10, trailing: 15))
                    
                    DistanceEntryView(distance: distance)
                    DurationEntryView(duration: duration)
                    PriceEntryView(price: price)
                    GreenPriceEntryView(greenPrice: greenPrice)
                }
            } else {
                VStack (spacing:0){
                    HStack {
                        Text("Recap")
                            .font(.title)
                            .foregroundStyle(AppColors.mainColor.opacity(0.8))
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Spacer()
                        
                        Button(action: {
                            infoTapped = true
                        }) {
                            Image(systemName: "info.circle")
                        }
                        .accessibilityIdentifier("infoGreenPriceButton")
                    }
                    .padding(EdgeInsets(top: 15, leading: 15, bottom: 10, trailing: 15))
                    
                    HStack {
                        VStack {
                            DistanceEntryView(distance: distance)
                            DurationEntryView(duration: duration)
                        }
                        VStack {
                            PriceEntryView(price: price)
                            GreenPriceEntryView(greenPrice: greenPrice)
                        }
                    }
                    .padding(.bottom, 5)
                }
            }
        }
        .sheet(isPresented: $infoTapped) {
            InfoGreenPriceView(isPresented: $infoTapped)
                .presentationDetents([.fraction(0.30)])
                .presentationCornerRadius(15)
                .overlay(Color.clear.accessibilityIdentifier("infoGreenPriceView"))
        }
    }
}

private struct DistanceEntryView: View {
    let distance: Float64
    
    var body: some View {
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
            Text(String(format: "%.1f", distance) + " Km")
                .font(.system(size: 25).bold())
                .bold()
                .foregroundColor(AppColors.mainColor.opacity(0.8))
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 5)
    }
}

private struct DurationEntryView: View {
    let duration: String
    
    var body: some View {
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
        
        Text(duration)
            .font(.system(size: 25).bold())
            .bold()
            .foregroundColor(AppColors.mainColor.opacity(0.8))
        Spacer()
    }
    .padding(.horizontal)
    .padding(.vertical, 5)
    
    }
}

private struct PriceEntryView: View {
    let price: Float64
    
    var body: some View {
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

            Text(String(format: "%.2f", price) + " €")
                .font(.system(size: 25).bold())
                .bold()
                .foregroundColor(AppColors.mainColor.opacity(0.8))
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 5)
    }
}

private struct GreenPriceEntryView: View {
    let greenPrice: Float64
    var body: some View {
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

                Text(String(format: "%.2f", greenPrice) + " €")
                .font(.system(size: 25).bold())
                .bold()
                .foregroundColor(AppColors.mainColor.opacity(0.8))
            Spacer()
        }
        .padding(EdgeInsets(top: 5, leading: 15, bottom: 10, trailing: 15))
    }
}


struct InfoGreenPriceView: View {
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
            .accessibilityIdentifier("infoGreenPriceCloseButton")
        }
        .padding(.horizontal)
        .padding(.top)
        
        ScrollView {
            VStack {
                Text("What Is The Green Price")
                    .font(.title)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .scaledToFit()
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                    .padding(.bottom, 5)
                Text("""
                The green price represents the total cost of your trip, combining the base fare with full carbon compensation. 
                Carbon offsets are achieved by planting trees at just €2 each, neutralizing your travel emissions.
                """)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal)
            .padding(.bottom)
            .overlay(Color.clear.accessibilityIdentifier("infoGreenPriceContent"))
        }
    }
}
