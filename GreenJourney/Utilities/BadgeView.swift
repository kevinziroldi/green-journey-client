import SwiftUI

struct BadgeView: View {
    var badges: [Badge]
    var dim: CGFloat
    var inline: Bool
    
    var body: some View {
        let allBadges = getBestBadges(badges: badges)
        if !inline {
            
            VStack(spacing: 5) { // Due righe
                HStack(spacing: 5) { // Prima riga
                    Image(allBadges[0].rawValue)
                        .resizable()
                        .scaledToFit()
                        .frame(width: dim, height: dim)
                    Image(allBadges[1].rawValue)
                        .resizable()
                        .scaledToFit()
                        .frame(width: dim, height: dim)
                }
                HStack(spacing: 5) { // Seconda riga
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
        else{
            HStack (spacing: 3) {
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
        }
        
    }
    
    private func getBestBadges(badges: [Badge]) -> [Badge] {
        var completedBadges: [Badge] = badges
        for group in Badge.allTypes {
            // checks if the badge is already represented
            if !completedBadges.contains(where: { group.contains($0) }) {
                // add base badge to the list
                if let baseBadge = group.first?.baseBadge {
                    completedBadges.append(baseBadge)
                }
            }
        }
        return completedBadges
    }
}
