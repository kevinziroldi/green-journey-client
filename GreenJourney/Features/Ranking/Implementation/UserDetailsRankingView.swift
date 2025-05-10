import SwiftUI

struct UserDetailsRankingView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @ObservedObject var viewModel: RankingViewModel
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @State var isPresenting: Bool = false
    
    var user: RankingElement
    @State private var legendTapped: Bool = false
    @State var progress: Float64 = 0
    
    var body: some View {
        VStack {
            if horizontalSizeClass == .compact {
                // iOS
                ScrollView {
                    VStack {
                        // title
                        RankingElementDetailsTitle(user: user)
                        
                        //badges
                        UserBadgesView(legendTapped: $legendTapped, badges: user.badges,inline: false, isPresenting: $isPresenting)
                        
                        // scores
                        ScoresView(scoreLongDistance: user.scoreLongDistance, scoreShortDistance: user.scoreShortDistance, isPresenting: $isPresenting)
                            .overlay(Color.clear.accessibilityIdentifier("scoresView"))
                        
                        //user aggregate data
                        RecapViewCompactDevice(viewModel: viewModel, user: user)
                        
                        Spacer()
                    }
                    .padding()
                }
                
            } else {
                // iPadOS
                ScrollView {
                    HStack {
                        Spacer()
                        VStack {
                            // title
                            RankingElementDetailsTitle(user: user)
                            
                            // badges
                            UserBadgesView(legendTapped: $legendTapped, badges: user.badges,inline: true, isPresenting: $isPresenting)
                            
                            // user aggregate data
                            HStack (alignment: .top) {
                                VStack {
                                    // scores
                                    ScoresView(scoreLongDistance: user.scoreLongDistance, scoreShortDistance: user.scoreShortDistance, isPresenting: $isPresenting)
                                    
                                    // user aggregate data
                                    RecapViewRegularDevice(viewModel: viewModel, user: user)
                                }
                                
                                // co2 emission
                                Co2EmissionView(co2Emitted: user.totalCo2Emitted, co2Compensated: user.totalCo2Compensated, progress: progress)
                            }
                            .fixedSize(horizontal: false, vertical: true)
                            
                            Spacer()
                        }
                        .frame(maxWidth: 800)
                        Spacer()
                    }
                }
            }
        }
        .background(colorScheme == .dark ? AppColors.backColorDark : AppColors.backColorLight)
        .sheet(isPresented: $legendTapped, onDismiss: {isPresenting = false}) {
            LegendBadgeView(isPresented: $legendTapped, isPresenting: $isPresenting)
                .presentationDetents([.fraction(0.95)])
                .presentationCornerRadius(15)
                .overlay(Color.clear.accessibilityIdentifier("infoBadgesView"))
        }
        .onAppear() {
            isPresenting = false
            if user.totalCo2Compensated >= 0.0 {
                if user.totalCo2Compensated >= user.totalCo2Emitted {
                    progress = 1.0
                } else {
                    progress = user.totalCo2Compensated / user.totalCo2Emitted
                }
            }
        }
    }
}

private struct RankingElementDetailsTitle: View {
    var user: RankingElement
    
    var body: some View {
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
    }
}

private struct RecapViewCompactDevice: View {
    @ObservedObject var viewModel: RankingViewModel
    var user: RankingElement
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(colorScheme == .dark ? AppColors.blockColorDark: Color(uiColor: .systemBackground))
                .shadow(radius: 3, x: 0, y: 3)
            VStack {
                Text("Recap")
                    .font(.title)
                    .foregroundStyle(AppColors.mainColor)
                    .padding(EdgeInsets(top: 15, leading: 15, bottom: 10, trailing: 0))
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                HStack {
                    Image(systemName: "road.lanes")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 35, height: 35)
                        .foregroundColor(AppColors.mainColor)
                    Text("Distance")
                        .font(.system(size: 20).bold())
                        .frame(maxWidth: 250, alignment: .leading)
                        .padding(.leading, 5)
                    Text(String(format: "%.1f", user.totalDistance) + " Km")
                        .font(.system(size: 22).bold())
                        .bold()
                        .foregroundColor(AppColors.mainColor.opacity(0.8))
                    
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical, 5)
                HStack {
                    Image(systemName: "clock")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 35, height: 35)
                        .foregroundColor(AppColors.mainColor)
                    
                    Text("Time")
                        .font(.system(size: 20).bold())
                        .padding(.leading, 5)
                        .frame(maxWidth: 250, alignment: .leading)
                    
                    Text(viewModel.computeTotalDuration(duration: user.totalDuration))
                        .font(.system(size: 22).bold())
                        .foregroundColor(AppColors.mainColor.opacity(0.8))
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical, 5)
                
                HStack {
                    Image(systemName: "carbon.dioxide.cloud")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 35, height: 35)
                        .foregroundColor(AppColors.green)
                    Text("CO\u{2082} emitted")
                        .font(.system(size: 20).bold())
                        .frame(maxWidth: 250, alignment: .leading)
                        .padding(.leading, 5)
                    Text(String(format: "%.0f", user.totalCo2Emitted) + " Kg")
                        .font(.system(size: 22).bold())
                        .foregroundColor(AppColors.green.opacity(0.8))
                    
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical, 5)
                
                HStack {
                    Image(systemName: "leaf")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 35, height: 35)
                        .foregroundColor(AppColors.green)
                    Text("CO\u{2082} compensated")
                        .font(.system(size: 20).bold())
                        .frame(maxWidth: 250, alignment: .leading)
                        .padding(.leading, 5)
                    Text(String(format: "%.0f", user.totalCo2Compensated) + " Kg")
                        .font(.system(size: 20).bold())
                        .foregroundColor(AppColors.green.opacity(0.8))
                    
                    
                    
                    Spacer()
                }
                .padding(EdgeInsets(top: 5, leading: 15, bottom: 10, trailing: 15))
            }
        }
        .padding(EdgeInsets(top: 5, leading: 15, bottom: 7, trailing: 15))
        .overlay(Color.clear.accessibilityIdentifier("userTravelsRecap"))
    }
}

private struct RecapViewRegularDevice: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    @ObservedObject var viewModel: RankingViewModel
    var user: RankingElement
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(colorScheme == .dark ? AppColors.blockColorDark: Color(uiColor: .systemBackground))
                .shadow(radius: 3, x: 0, y: 3)
            VStack {
                Text("Recap")
                    .font(.title)
                    .foregroundStyle(AppColors.mainColor)
                    .padding(EdgeInsets(top: 15, leading: 15, bottom: 10, trailing: 0))
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                HStack {
                    Image(systemName: "road.lanes")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 35, height: 35)
                        .foregroundColor(AppColors.mainColor)
                    Text("Distance")
                        .font(.system(size: 20).bold())
                        .frame(maxWidth: 250, alignment: .leading)
                        .padding(.leading, 5)
                    Text(String(format: "%.1f", user.totalDistance) + " Km")
                        .font(.system(size: 22).bold())
                        .bold()
                        .foregroundColor(AppColors.mainColor.opacity(0.8))
                    
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical, 5)
                HStack {
                    Image(systemName: "clock")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 35, height: 35)
                        .foregroundColor(AppColors.mainColor)
                    
                    Text("Time")
                        .font(.system(size: 20).bold())
                        .padding(.leading, 5)
                        .frame(maxWidth: 250, alignment: .leading)
                    
                    Text(viewModel.computeTotalDuration(duration: user.totalDuration))
                        .font(.system(size: 22).bold())
                        .foregroundColor(AppColors.mainColor.opacity(0.8))
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical, 5)
            }
            .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 15))
        }
        .padding(EdgeInsets(top: 5, leading: 15, bottom: 7, trailing: 15))
        .overlay(Color.clear.accessibilityIdentifier("userTravelsRecap"))
    }
}

private struct Co2EmissionView: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    var co2Emitted: Double
    var co2Compensated: Double
    var progress: Double
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(colorScheme == .dark ? AppColors.blockColorDark: Color(uiColor: .systemBackground))
                .shadow(radius: 3, x: 0, y: 3)
            VStack {
                Text("Compensation Recap")
                    .font(.title)
                    .foregroundStyle(.mint)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                GeometryReader { geometry in
                    SemicircleCo2ChartView(progress: progress, height: 170, width: 200, lineWidth: 16)
                        .position(x: geometry.size.width/2, y: geometry.size.height/2)
                    VStack {
                        Text("Compensated")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .scaledToFit()
                            .minimumScaleFactor(0.6)
                            .lineLimit(1)
                        Text(String(format: "%.0f", co2Compensated) + " Kg")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                    .position(x: geometry.size.width/2 - 90, y: geometry.size.height/2 + 120)
                    .foregroundStyle(AppColors.green)
                    VStack {
                        Text("Emitted")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .scaledToFit()
                            .minimumScaleFactor(0.6)
                            .lineLimit(1)
                        Text(String(format: "%.0f", co2Emitted) + " Kg")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                    .foregroundStyle(AppColors.red)
                    .position(x: geometry.size.width/2 + 90, y: geometry.size.height/2 + 120)
                }
                .frame(height: 250)
                Spacer()
            }
            .padding()
        }
        .padding(EdgeInsets(top: 7, leading: 15, bottom: 7, trailing: 15))
        .overlay(Color.clear.accessibilityIdentifier("co2EmissionView"))
    }
}
