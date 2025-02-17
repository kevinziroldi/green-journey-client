import SwiftUI

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
