import SwiftUI

struct ScoresView: View {
    var scoreLongDistance: Float64
    var scoreShortDistance: Float64
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(uiColor: .systemBackground))
                .shadow(color: .pink.opacity(0.3), radius: 5, x: 0, y: 3)
            VStack (spacing:0){
                Text("Scores")
                    .font(.title)
                    .foregroundStyle(.pink.opacity(0.8))
                    .padding()
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                InfoRow(title: "Short distance", value: String(format: "%.1f", scoreShortDistance), icon: "trophy", color: .pink, imageValue: false, imageValueString: nil)
                
                InfoRow(title: "Long distance", value: String(format: "%.1f", scoreLongDistance), icon: "trophy", color: .pink, imageValue: false, imageValueString: nil)
            }
            .padding(.bottom, 7)
        }
        .padding(EdgeInsets(top: 7, leading: 15, bottom: 7, trailing: 15))
    }
}
