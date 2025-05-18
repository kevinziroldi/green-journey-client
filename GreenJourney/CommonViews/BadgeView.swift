import SwiftUI

struct BadgeView: View {
    var badges: [Badge]
    var dim: CGFloat
    var inline: Bool
    var allBadgeTypes: Bool
    
    var body: some View {
        let allBadges = allBadgeTypes ? getBestBadges(badges: badges) : badges
        
        if inline {
            // display on 1 row
            
            HStack(spacing: 5) {
                Image(allBadges[0].rawValue)
                    .resizable()
                    .scaledToFit()
                    .frame(width: dim, height: dim)
                Image(allBadges[1].rawValue)
                    .resizable()
                    .scaledToFit()
                    .frame(width: dim, height: dim)
                Image(allBadges[2].rawValue)
                    .resizable()
                    .scaledToFit()
                    .frame(width: dim, height: dim)
                Image(allBadges[3].rawValue)
                    .resizable()
                    .scaledToFit()
                    .frame(width: dim, height: dim)
            }
        } else {
            // display on 2 rows
            
            VStack(spacing: 5) {
                HStack(spacing: 5) { // first line
                    Image(allBadges[0].rawValue)
                        .resizable()
                        .scaledToFit()
                        .frame(width: dim, height: dim)
                    Image(allBadges[1].rawValue)
                        .resizable()
                        .scaledToFit()
                        .frame(width: dim, height: dim)
                }
                HStack(spacing: 5) { // second line
                    Image(allBadges[2].rawValue)
                        .resizable()
                        .scaledToFit()
                        .frame(width: dim, height: dim)
                    Image(allBadges[3].rawValue)
                        .resizable()
                        .scaledToFit()
                        .frame(width: dim, height: dim)
                }
            }
        }
    }
    
    private func getBestBadges(badges: [Badge]) -> [Badge] {
        var completedBadges: [Badge] = []
        
        for group in Badge.allTypes {
            // if badge present, add, else add base badge
            if let existing = badges.first(where: { group.contains($0) }) {
                completedBadges.append(existing)
            } else {
                if let base = group.first?.baseBadge {
                    // add base badge to the list
                    completedBadges.append(base)
                }
            }
        }
        return completedBadges
    }
}
