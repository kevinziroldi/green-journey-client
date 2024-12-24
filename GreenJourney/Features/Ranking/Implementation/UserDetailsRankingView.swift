import SwiftUI

struct UserDetailsRankingView: View {
    @ObservedObject var viewModel: RankingViewModel
    @Environment(\.colorScheme) var colorScheme: ColorScheme

    @Binding var navigationPath: NavigationPath

    var user: RankingElement
    @State private var legendTapped: Bool = false
    var body: some View {
        ZStack {
            VStack {
                Text("User Details")
                    .font(.largeTitle)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                
                
                Text(user.firstName + " " + user.lastName)
                    .font(.title)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .padding(EdgeInsets(top: 30, leading: 15, bottom: 5, trailing: 15))
                    .fontWeight(.semibold)
                    
                
                HStack {
                    BadgeView(badges: user.badges, dim: 85, inline: true)
                    Button(action: {
                        legendTapped = true
                    }) {
                        Image(systemName: "info.circle")
                            .font(.title3)
                            .foregroundStyle(.gray)
                        
                    }
                }
                .padding(EdgeInsets(top: 10, leading: 15, bottom: 20, trailing: 15))
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(colorScheme == .dark ? .white : .black, lineWidth: 2)
                        .shadow(radius: 10)
                    
                    VStack {
                        HStack {
                            Image (systemName: "road.lanes")
                                .font(.largeTitle)
                                .frame(maxWidth: 40)
                            
                            Spacer()
                            
                            Text(String(format: "%.1f", user.totalDistance) + " Km")
                                .font(.title2)
                                .fontWeight(.semibold)
                            Text("traveled")
                                .font(.title2)
                            
                            Spacer()
                        }
                        .padding(.vertical, 7)
                        
                        HStack {
                            Image(systemName: "clock")
                                .font(.largeTitle)
                                .frame(maxWidth: 40)
                                .foregroundStyle(.cyan)
                            
                            Spacer()
                            
                            Text(viewModel.computeTotalDuration(duration: user.totalDuration))
                                .font(.title2)
                                .fontWeight(.semibold)
                            Text("in travel")
                                .font(.title2)
                            
                            Spacer()
                        }
                        .padding(.vertical, 7)
                    }
                    .padding()
                }
                .fixedSize(horizontal: false, vertical: true)
                .padding(EdgeInsets(top: 10, leading: 15, bottom: 30, trailing: 15))
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(colorScheme == .dark ? .white : .black, lineWidth: 2)
                        .shadow(radius: 10)
                    
                    VStack {
                        HStack {
                            Image(systemName: "carbon.dioxide.cloud")
                                .font(.largeTitle)
                                .frame(maxWidth: 40)
                                .foregroundStyle(.red)
                            Spacer()
                            Text(String(format: "%.1f", user.totalCo2Emitted) + " Kg")
                                .font(.title2)
                                .fontWeight(.semibold)
                            Text("CO2 emitted")
                                .font(.title2)
                            Spacer()
                        }
                        .padding(.vertical, 7)
                        
                        HStack {
                            Image(systemName: "leaf")
                                .font(.largeTitle)
                                .frame(maxWidth: 40)
                                .foregroundStyle(.green)
                            Spacer()
                            Text(String(format: "%.1f", user.totalCo2Compensated) + " Kg")
                                .font(.title2)
                                .fontWeight(.semibold)
                            Text("CO2 compensated")
                                .font(.title2)
                            Spacer()
                        }
                        .padding(.vertical, 7)
                    }
                    .padding()
                }
                .fixedSize(horizontal: false, vertical: true)
                .padding(EdgeInsets(top: 10, leading: 15, bottom: 30, trailing: 15))
                Spacer()
            }
            .blur(radius: (legendTapped) ? 1 : 0)
            
            
            
            if legendTapped {
                LegendView(onClose: {
                    legendTapped = false
                })
            }
        }
        .background(.green.opacity(0.1))
    }
}

struct LegendView: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    var onClose: () -> Void
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray, lineWidth: 2)
                .fill(colorScheme == .dark ? Color.black : Color.white)
                .shadow(radius: 10)
            VStack {
                Spacer()
                HStack {
                    Image(Badge.badgeDistanceLow.rawValue)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 65, height: 65)
                        .shadow(radius: 10)
                    Image(systemName: "arrowshape.right")
                        .frame(width: 20, height: 20)
                    
                    Text("how much distance a user has traveled")
                    Spacer()
                }
                HStack {
                    Image(Badge.badgeCompensationLow.rawValue)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 65, height: 65)
                        .shadow(radius: 10)
                    Image(systemName: "arrowshape.right")
                        .frame(width: 20, height: 20)
                    Text("how much a user has compensated")
                    Spacer()
                }
                HStack {
                    Image(Badge.badgeTravelsNumberLow.rawValue)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 65, height: 65)
                        .shadow(radius: 10)
                    Image(systemName: "arrowshape.right")
                        .frame(width: 20, height: 20)
                    Text("how many travels a user has done")
                    Spacer()
                }
                HStack {
                    Image(Badge.badgeEcologicalChoiceLow.rawValue)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 65, height: 65)
                        .shadow(radius: 10)
                    Image(systemName: "arrowshape.right")
                        .frame(width: 20, height: 20)
                    Text("how much a user has been ecofriendly")
                    Spacer()
                }
                Spacer()
                Button("Close") {
                    onClose()
                }
                .buttonStyle(.bordered)
                Spacer()
            }
            .padding()

        }
        .frame(width: 330, height: 400)
        
    }
}

