import SwiftUI

struct DetailedRatingsView: View {
    let review: Review
    var body: some View {
        HStack {
            Spacer()
            
            Image(systemName: "bus")
                .resizable()
                .scaledToFit()
                .frame(width: 23, height: 23)
                .foregroundColor(AppColors.mainColor)
            
            Text(String(format: "%.0f", review.localTransportRating))
            Spacer()
            Divider()
            Spacer()
            
            Image(systemName: "tree")
                .resizable()
                .scaledToFit()
                .frame(width: 23, height: 23)
                .foregroundColor(AppColors.mainColor)
            
            Text(String(format: "%.0f", review.greenSpacesRating))
            Spacer()
            Divider()
            Spacer()
            
            Image(systemName: "trash")
                .resizable()
                .scaledToFit()
                .frame(width: 23, height: 23)
                .foregroundColor(AppColors.mainColor)
            
            Text(String(format: "%.0f", review.wasteBinsRating))
            Spacer()
        }
        .frame(height: 30)
    }
}
