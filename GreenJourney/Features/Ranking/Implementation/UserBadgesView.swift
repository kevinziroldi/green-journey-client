import SwiftUI

struct UserBadgesView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Binding var legendTapped: Bool
    var badges: [Badge]
    var inline: Bool
    
    var body: some View {
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color(uiColor: .systemBackground))
                    .shadow(radius: 3, x: 0, y: 3)
                VStack(spacing:0) {
                    HStack {
                        Text("Badges")
                            .font(.title)
                            .foregroundStyle(AppColors.mainColor)
                            .fontWeight(.semibold)
                        Spacer()
                        Button(action: {
                            legendTapped = true
                        }) {
                            Image(systemName: "info.circle")
                                .font(.title3)
                        }
                        .accessibilityIdentifier("infoBadgesButton")
                    }
                    .padding(EdgeInsets(top: 15, leading: 15, bottom: 0, trailing: 15))
                    
                    HStack{
                        if horizontalSizeClass == .compact {
                            if inline {
                                BadgeView(badges: badges, dim: (UIScreen.main.bounds.width - 120)/4, inline: inline)
                                    .padding()
                            }
                            else {
                                BadgeView(badges: badges, dim: (UIScreen.main.bounds.width - 120)/2, inline: inline)
                                    .padding()
                            }
                        } else {
                            BadgeView(badges: badges, dim: (UIScreen.main.bounds.width/2)/4, inline: inline)
                                .padding()
                        }
                    }
                }
            }
            .overlay(Color.clear.accessibilityIdentifier("userBadgesView"))
        
        .padding(EdgeInsets(top: 5, leading: 15, bottom: 7, trailing: 15))
    }
}
