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
                                Spacer()
                            }
                            .padding(EdgeInsets(top: 15, leading: 15, bottom: 0, trailing: 0))
                            HStack{
                                BadgeView(badges: user.badges, dim: 80, inline: true)
                                    .padding()
                                
                            }
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
                                    //.frame(width: 180, alignment: .leading)
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
                                
                                Text(String(format: "%.2f", user.totalCo2Emitted) + " Kg")
                                    .font(.system(size: 22).bold())
                                    .bold()
                                    .foregroundColor(.red.opacity(0.8))
                                    //.frame(width: 110, alignment: .leading)
                                
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
                                
                                Text(String(format: "%.2f", user.totalCo2Compensated) + " Kg")
                                    .font(.system(size: 20).bold())
                                    .bold()
                                    .foregroundColor(.green.opacity(0.8))
                                    //.frame(width: 110, alignment: .leading)

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

                    /*
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
                    .padding(EdgeInsets(top: 10, leading: 15, bottom: 30, trailing: 15))*/
                    Spacer()
                }
            }
            .padding()
            .blur(radius: (legendTapped) ? 1 : 0)
            
            
            
            if legendTapped {
                LegendBadgeView(onClose: {
                    legendTapped = false
                })
            }
        }
        .background(.green.opacity(0.1))
    }
}
