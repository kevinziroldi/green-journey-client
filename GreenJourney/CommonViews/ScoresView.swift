import SwiftUI

struct ScoresView: View {
    @State var infoTapped: Bool = false
    var scoreLongDistance: Float64
    var scoreShortDistance: Float64
    @Binding var isPresenting: Bool
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Scores")
                    .font(.title)
                    .foregroundStyle(AppColors.mainColor)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                
                Button(action: {
                    if !isPresenting {
                        isPresenting = true
                        infoTapped = true
                    }
                }) {
                    Image(systemName: "info.circle")
                        .font(.title3)
                }
                .accessibilityIdentifier("infoScoresButton")
            }
            .padding(EdgeInsets(top: 15, leading: 15, bottom: 5, trailing: 15))
            
            InfoRowView(title: "Long Distance",
                        value: String(format: "%.1f", scoreLongDistance),
                        icon: "trophy",
                        isSystemIcon: true,
                        color: AppColors.mainColor,
                        imageValue: false,
                        imageValueString: nil)
            
            InfoRowView(title: "Short Distance",
                        value: String(format: "%.1f", scoreShortDistance),
                        icon: "medal",
                        isSystemIcon: true,
                        color: AppColors.mainColor,
                        imageValue: false,
                        imageValueString: nil)
        }
        .overlay(Color.clear.accessibilityIdentifier("userScoresView"))
        .padding(.bottom, 7)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(colorScheme == .dark ? AppColors.blockColorDark: Color(uiColor: .systemBackground))
                .shadow(radius: 3, x: 0, y: 3)
        )
        .sheet(isPresented: $infoTapped, onDismiss: {isPresenting = false}) {
            InfoScoresView(isPresented: $infoTapped, isPresenting: $isPresenting)
                .presentationDetents([.fraction(0.80)])
                .presentationCornerRadius(15)
                .overlay(Color.clear.accessibilityIdentifier("infoScoresView"))
        }
        .padding(EdgeInsets(top: 7, leading: 15, bottom: 7, trailing: 15))
    }
}

struct InfoScoresView: View {
    @Binding var isPresented: Bool
    @Binding var isPresenting: Bool
    var body: some View {
        HStack {
            Spacer()
            Button(action: {
                isPresenting = false
                isPresented = false
            }) {
                Text("Done")
                    .fontWeight(.bold)
            }
            .accessibilityIdentifier("infoScoresCloseButton")
        }
        .padding(.horizontal)
        .padding(.top)
        
        ScrollView {
            VStack {
                Text("What Are The Scores")
                    .font(.title)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .scaledToFit()
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                    .padding(.bottom, 5)
                VStack {
                    Text("""
                Trips are categorized based on the distance traveled. Journeys of 800 kilometers or less are considered 
                """) +
                    Text("short").bold() +
                    Text("""
                , while those exceeding 800 kilometers are labeled 
                """) +
                    Text("long").bold() +
                    Text("""
                .
                """)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("How We Calculate The Scores")
                    .font(.title)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .scaledToFit()
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                    .padding(.top, 30)
                    .padding(.bottom, 5)
                VStack {
                    Text("""
                The score calculation is based on two main factors: the sustainability of the travel choice and the extent to which the user has offset the trip's carbon footprint. 
                First, the app evaluates how 
                """) +
                    Text("eco-friendly ").bold() +
                    Text("""
                the chosen mode of transportation is considering factors such as fuel efficiency and environmental impact.
                Then, it assesses the level of 
                """) +
                    Text("compensation ").bold() +
                    Text("""
                or carbon offset applied by the user.
                For every trip that is fully compensated, a 
                """) +
                    Text("bonus ").bold() +
                    Text("""
                score is awarded, further incentivizing users to mitigate their environmental impact.
                
                Together, these scores provide a transparent, quantifiable measure of a trip’s overall sustainability, guiding users towards making greener travel decisions.
                """)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal)
            .padding(.bottom)
            .overlay(Color.clear.accessibilityIdentifier("infoScoresContent"))
        }
    }
}
