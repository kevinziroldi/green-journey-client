import SwiftUI

struct InfoRowView: View {
    let title: String
    let value: String
    let icon: String
    let isSystemIcon: Bool
    let color: Color
    let imageValue: Bool
    let imageValueString: String?
    
    var body: some View {
        HStack {
            HStack {
                if isSystemIcon {
                    Image(systemName: icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .foregroundColor(color)
                        .padding(.vertical, 2)
                } else {
                    Image(icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .foregroundColor(color)
                }
                
                Text(title)
                    .font(.system(size: 20).bold())
                    .scaledToFit()
                    .minimumScaleFactor(0.8)
                    .lineLimit(1)
                    .foregroundColor(.primary)
                    .padding(.leading, 10)
                
                if title != "" {
                    Spacer()
                }
                if !imageValue {
                    Text(value)
                        .font(.system(size: 23).bold())
                        .bold()
                        .scaledToFit()
                        .minimumScaleFactor(0.8)
                        .lineLimit(1)
                        .foregroundColor(color.opacity(0.8))
                    
                }
                else {
                    if let imageValueString = imageValueString {
                        Image(systemName: imageValueString)
                            .resizable()
                            .fontWeight(.semibold)
                            .scaledToFit()
                            .frame(width: 45, height: 45)
                            .foregroundColor(color.opacity(0.8))
                    }
                    
                }
            }
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 5)
        
    }
}

