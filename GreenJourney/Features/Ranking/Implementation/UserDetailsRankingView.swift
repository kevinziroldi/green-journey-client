import SwiftUI

struct UserDetailsRankingView: View {
    @ObservedObject var viewModel: RankingViewModel
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    @Binding var navigationPath: NavigationPath
    
    var user: RankingElement
    @State private var legendTapped: Bool = false
    var body: some View {
        ZStack {
            ScrollView {
                VStack {
                    Text("User Details")
                        .font(.system(size: 32).bold())
                        .padding()
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .accessibilityIdentifier("userDetailsTitle")
                    
                    
                    Text(user.firstName + " " + user.lastName)
                        .font(.title)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                        .padding(EdgeInsets(top: 30, leading: 15, bottom: 5, trailing: 15))
                        .fontWeight(.semibold)
                        .accessibilityIdentifier("userName")
                    
                    //badges
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color(uiColor: .systemBackground))
                            .shadow(color: .blue.opacity(0.3), radius: 5, x: 0, y: 3)
                        VStack (spacing:0){
                            HStack {
                                Text("Badges")
                                    .font(.title)
                                    .foregroundStyle(.blue.opacity(0.8))
                                    .fontWeight(.semibold)
                                
                                Button(action: {
                                    legendTapped = true
                                }) {
                                    Image(systemName: "info.circle")
                                        .font(.title3)
                                        .foregroundStyle(.gray)
                                }
                                .accessibilityIdentifier("badgesInfoButton")
                                
                                Spacer()
                            }
                            .padding(EdgeInsets(top: 15, leading: 15, bottom: 0, trailing: 0))
                            
                            HStack{
                                BadgeView(badges: user.badges, dim: 130, inline: false)
                                    .padding()
                            }
                            .overlay(Color.clear.accessibilityIdentifier("userBadges"))
                        }
                    }
                    .padding(EdgeInsets(top: 5, leading: 15, bottom: 7, trailing: 15))
                    
                    //user aggregate data
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color(uiColor: .systemBackground))
                            .shadow(color: .indigo.opacity(0.3), radius: 5, x: 0, y: 3)
                        VStack {
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
                                        .frame(width: 50, height: 50)
                                    
                                    Image(systemName: "road.lanes")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 35, height: 35)
                                        .foregroundColor(.indigo)
                                }
                                
                                
                                
                                Text(String(format: "%.1f", user.totalDistance) + " Km")
                                    .font(.system(size: 22).bold())
                                    .bold()
                                    .foregroundColor(.indigo.opacity(0.8))
                                    //.frame(width: 180, alignment: .leading)

                                Text("traveled")
                                    .font(.system(size: 20).bold())
                                    .foregroundColor(.indigo.opacity(0.8))
                                    .padding(.leading, 5)
                                Spacer()
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 5)
                            HStack {
                                ZStack {
                                    Circle()
                                        .fill(.blue.opacity(0.2))
                                        .frame(width: 50, height: 50)
                                    
                                    Image(systemName: "clock")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 35, height: 35)
                                        .foregroundColor(.blue)
                                }
                                
                                Text(viewModel.computeTotalDuration(duration: user.totalDuration))
                                    .font(.system(size: 22).bold())
                                    .bold()
                                    .foregroundColor(.blue.opacity(0.8))
                                
                                Text("in travel")
                                    .font(.system(size: 20).bold())
                                    .foregroundColor(.blue.opacity(0.8))
                                    .padding(.leading, 5)
                                Spacer()
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 5)
                            
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
                                
                                Text(String(format: "%.0f", user.totalCo2Emitted) + " Kg")
                                    .font(.system(size: 22).bold())
                                    .bold()
                                    .foregroundColor(.red.opacity(0.8))
                                
                                Text("Co2 emitted")
                                    .font(.system(size: 20).bold())
                                    .foregroundColor(.red.opacity(0.8))
                                    .padding(.leading, 5)
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
                                
                                Text(String(format: "%.0f", user.totalCo2Compensated) + " Kg")
                                    .font(.system(size: 20).bold())
                                    .bold()
                                    .foregroundColor(.green.opacity(0.8))

                                Text("Co2 compensated")
                                    .font(.system(size: 20).bold())
                                    .foregroundColor(.green.opacity(0.8))
                                    .padding(.leading, 5)

                                Spacer()
                            }
                            .padding(EdgeInsets(top: 5, leading: 15, bottom: 10, trailing: 15))
                        }
                    }
                    .padding(EdgeInsets(top: 5, leading: 15, bottom: 7, trailing: 15))
                    .overlay(Color.clear.accessibilityIdentifier("userTravelsRecap"))
                    
                    Spacer()
                }
                .padding()
            }
            .blur(radius: (legendTapped) ? 1 : 0)
            
            if legendTapped {
                LegendBadgeView(onClose: {
                    legendTapped = false
                })
            }
        }
    }
}
