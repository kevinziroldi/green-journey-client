enum TabViewElement: Hashable, CaseIterable, Identifiable {
    case Ranking
    case Reviews
    case SearchTravel
    case MyTravels
    case Dashboard
    
    case UserPreferences
    
    var id: Self { self }
    
    var title: String {
        switch self {
        case .Ranking:      return "Ranking"
        case .Reviews:      return "Reviews"
        case .SearchTravel: return "Search"
        case .MyTravels:    return "My travels"
        case .Dashboard:    return "Dashboard"
        case .UserPreferences: return "User preferences"
        }
    }
    
    var systemImage: String {
        switch self {
        case .Ranking:      return "trophy"
        case .Reviews:      return "star.fill"
        case .SearchTravel: return "location"
        case .MyTravels:    return "airplane"
        case .Dashboard:    return "chart.bar.xaxis.ascending"
        case .UserPreferences: return "person"
        }
    }
    
    var accessibilityIdentifier: String {
        switch self {
        case .Ranking:      return "rankingTabViewElement"
        case .Reviews:      return "citiesReviewsTabViewElement"
        case .SearchTravel: return "travelSearchTabViewElement"
        case .MyTravels:    return "myTravelsTabViewElement"
        case .Dashboard:    return "dashboardTabViewElement"
        case .UserPreferences: return "userPreferencesTabViewElement"
        }
    }
}
