import SwiftUI
import SwiftData

struct DashboardView: View {
    @EnvironmentObject private var viewModel: DashboardViewModel
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        Text("DashboardView")
    }
}
