enum TabViewElement: Hashable, CaseIterable, Identifiable {
    case Ranking
    case Reviews
    case SearchTravel
    case MyTravels
    case Dashboard

    var id: Self { self } 

    var title: String {
        switch self {
        case .Ranking:      return "Ranking"
        case .Reviews:      return "Reviews"
        case .SearchTravel: return "From-To"
        case .MyTravels:    return "My Travels"
        case .Dashboard:    return "Dashboard"
        }
    }
    
    var systemImage: String {
        switch self {
        case .Ranking:      return "trophy"
        case .Reviews:      return "star.fill"
        case .SearchTravel: return "location"
        case .MyTravels:    return "airplane"
        case .Dashboard:    return "house"
        }
    }
    
    var accessibilityIdentifier: String {
        switch self {
        case .Ranking:      return "rankingTabViewElement"
        case .Reviews:      return "citiesReviewsTabViewElement"
        case .SearchTravel: return "travelSearchTabViewElement"
        case .MyTravels:    return "myTravelsTabViewElement"
        case .Dashboard:    return "dashboardTabViewElement"
        }
    }
}
