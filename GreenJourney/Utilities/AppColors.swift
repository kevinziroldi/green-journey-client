import SwiftUI

enum AppColors {
    // main color
    static let mainColor = Color(red: 10/255, green: 159/255, blue: 183/255)
    
    // travel color
    static let ecoGreenTravel = LinearGradient(colors: [Color(red: 102/255, green: 187/255, blue: 106/255), .mint], startPoint: .bottom, endPoint: .top)
    static let ecoYellowTravel = LinearGradient(colors: [Color(red: 255/255, green: 202/255, blue: 40/255), .orange], startPoint: .bottom, endPoint: .top)
    static let ecoRedTravel = LinearGradient(colors: [Color(red: 184/255, green: 56/255, blue: 53/255), .red], startPoint: .bottom, endPoint: .top)
    
   /* static let ecoGreenTravel = LinearGradient(colors: [Color(red: 178/255, green: 223/255, blue: 181/255), Color.mint.opacity(0.6)], startPoint: .bottom, endPoint: .top)
    static let ecoYellowTravel = LinearGradient(colors: [Color(red: 255/255, green: 236/255, blue: 179/255), Color.orange.opacity(0.6)], startPoint: .bottom, endPoint: .top)
    static let ecoRedTravel = LinearGradient(colors: [Color(red: 239/255, green: 154/255, blue: 154/255), Color.red.opacity(0.6)], startPoint: .bottom, endPoint: .top)
    */
    
    static let backColorLight = Color(red: 245/255, green: 245/255, blue: 245/255)
    static let backColorDark = Color(red: 20/255, green: 20/255, blue: 20/255)
    
    // custom colors 
    static let green = Color(red: 115/255, green: 186/255, blue: 114/255)
    static let orange = Color(red: 255/255, green: 162/255, blue: 13/255)
    static let blue = Color(red: 54/255, green: 117/255, blue: 158/255)
    static let red = Color(red: 227/255, green: 84/255, blue: 79/255)
    static let purple = Color(red: 222/255, green: 115/255, blue: 176/255)
}

