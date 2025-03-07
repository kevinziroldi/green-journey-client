import SwiftUI

struct UserDetailsRankingView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @ObservedObject var viewModel: RankingViewModel
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @Binding var navigationPath: NavigationPath
    
    var user: RankingElement
    @State private var legendTapped: Bool = false
    
    var body: some View {
        if horizontalSizeClass == .compact {
            // iOS
            ScrollView {
                VStack {
                    // title
                    RankingElementDetailsTitle(user: user)
                    
                    //badges
                    UserDetailsBadgesView(inline: false, user: user, legendTapped: $legendTapped)
                    
                    //user aggregate data
                    RecapViewCompactDevice(viewModel: viewModel, user: user)
                    
                    Spacer()
                }
                .padding()
            }
            .sheet(isPresented: $legendTapped) {
                LegendBadgeView(isPresented: $legendTapped)
                    .presentationDetents([.large])
                    .presentationCornerRadius(30)
            }
        } else {
            // iPadOS
            ScrollView {
                VStack {
                    // title
                    RankingElementDetailsTitle(user: user)
                    
                    // badges
                    UserDetailsBadgesView(inline: true, user: user, legendTapped: $legendTapped)
                    
                    // user aggregate data
                    HStack {
                        VStack {
                            // scores
                            ScoresView(scoreLongDistance: user.scoreLongDistance, scoreShortDistance: user.scoreShortDistance)
                            
                            // user aggregate data
                            RecapViewRegularDevice(viewModel: viewModel, user: user)
                        }
                        
                        // co2 emission
                        Co2EmissionView(co2Emitted: user.totalCo2Emitted, co2Compensated: user.totalCo2Compensated, progress: user.totalCo2Compensated / user.totalCo2Emitted)
                    }
                    Spacer()
                }
                .padding()
            }
            .sheet(isPresented: $legendTapped) {
                LegendBadgeView(isPresented: $legendTapped)
                    .presentationDetents([.large])
                    .presentationCornerRadius(30)
            }
        }
    }
}

struct RankingElementDetailsTitle: View {
    var user: RankingElement
    
    var body: some View {
        Text("User details")
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
    }
}

struct UserDetailsBadgesView: View {
    var inline: Bool
    var user: RankingElement
    @Binding var legendTapped: Bool
    
    var body: some View {
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
                    BadgeView(badges: user.badges, dim: 150, inline: inline)
                        .padding()
                }
                .overlay(Color.clear.accessibilityIdentifier("userBadges"))
            }
        }
        .padding(EdgeInsets(top: 5, leading: 15, bottom: 7, trailing: 15))
    }
}

struct RecapViewCompactDevice: View {
    @ObservedObject var viewModel: RankingViewModel
    var user: RankingElement
    
    var body: some View {
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
    }
}

struct RecapViewRegularDevice: View {
    @ObservedObject var viewModel: RankingViewModel
    var user: RankingElement
    
    var body: some View {
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
            }
            .padding(EdgeInsets(top: 5, leading: 15, bottom: 10, trailing: 15))
        }
        .padding(EdgeInsets(top: 5, leading: 15, bottom: 7, trailing: 15))
        .overlay(Color.clear.accessibilityIdentifier("userTravelsRecap"))
    }
}
 
struct Co2EmissionView: View {
    var co2Emitted: Double
    var co2Compensated: Double
    var progress: Double
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(uiColor: .systemBackground))
                .shadow(color: .green.opacity(0.3), radius: 5, x: 0, y: 3)
            VStack {
                Text("Compensation recap")
                    .font(.title)
                    .foregroundStyle(.mint.opacity(0.8))
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                SemicircleCo2Chart(progress: progress, height: 170, width: 200, lineWidth: 16)
                    .padding(.top, 30)
                HStack {
                    VStack {
                        Text("Compensated")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(String(format: "%.0f", co2Compensated) + " Kg")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.leading, 20)
                    .foregroundStyle(.green)
                    VStack {
                        Text("Emitted")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(String(format: "%.0f", co2Emitted) + " Kg")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.leading, 40)
                    .foregroundStyle(.red)
                }
            }
            .padding()
        }
        .padding(EdgeInsets(top: 7, leading: 15, bottom: 7, trailing: 15))
    }
}
