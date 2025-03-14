import SwiftUI

struct InfoCompensationView: View {
    @Binding var isPresented: Bool
    var body: some View {
        
        HStack {
            Spacer()
            Button(action: {
                isPresented = false
            }) {
                Text("Done")
                    .fontWeight(.bold)
            }
            .accessibilityIdentifier("infoCloseButton")
        }
        .padding(.horizontal)
        .padding(.top)
                
        ScrollView {
            VStack {
                Text("Travel Sustainably")
                    .font(.title)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .scaledToFit()
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                    .padding(.bottom, 5)
                
                Text("Traveling has an environmental impact, but you can take action to reduce it. Every trip you take produces carbon emissions, contributing to climate change. By offsetting your Co2 footprint, you help balance these emissions and make your journeys more sustainable.")
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("How We Offset Carbon")
                    .font(.title)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .scaledToFit()
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                    .padding(.top, 30)
                    .padding(.bottom, 5)
                
                Text("""
                We make it easy for you to compensate for your travel impact. 
                Our approach is simple: we plant trees! Each tree absorbs an estimated 75 kg of Co2 over its lifetime, making a real difference for the planet. 
                And the best part? 
                Planting a tree costs only €2, making carbon offsetting both affordable and effective.
                Join us in making travel greener
                """)
                .frame(maxWidth: .infinity, alignment: .leading)
                Text("Small actions lead to big changes!")
                    .font(.headline)
                    .padding(.top)
            }
            .padding(.bottom)
            .padding(.horizontal)
            .overlay(Color.clear.accessibilityIdentifier("infoCompensationContent"))
        }
    }
}
