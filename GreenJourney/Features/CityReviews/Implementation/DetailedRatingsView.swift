import SwiftUI

struct DetailedRatingsView: View {
    let review: Review
    var body: some View {
        HStack {
            Spacer()
            ZStack {
                Circle()
                    .fill(.blue.opacity(0.2))
                    .frame(width: 27, height: 27)
                
                Image(systemName: "bus")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
                    .foregroundColor(.blue)
            }
            Text(String(format: "%.0f", review.localTransportRating))
            Spacer()
            Divider()
            Spacer()
            ZStack {
                Circle()
                    .fill(.green.opacity(0.2))
                    .frame(width: 27, height: 27)
                
                Image(systemName: "tree")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
                    .foregroundColor(.green)
            }
            Text(String(format: "%.0f", review.greenSpacesRating))
            Spacer()
            Divider()
            Spacer()
            ZStack {
                Circle()
                    .fill(.orange.opacity(0.2))
                    .frame(width: 27, height: 27)
                
                Image(systemName: "trash")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
                    .foregroundColor(.orange)
            }
            Text(String(format: "%.0f", review.wasteBinsRating))
            Spacer()
        }
        .frame(height: 30)
    }
}
