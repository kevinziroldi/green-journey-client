enum NavigationDestination: Hashable {
    case LoginView
    case SignupView(AuthenticationViewModel)
    case EmailVerificationView(AuthenticationViewModel)
    case OutwardOptionsView(String, String, TravelSearchViewModel)
    case ReturnOptionsView(String, String, TravelSearchViewModel)
    case OptionDetailsView(String, String, TravelOption, TravelSearchViewModel)
    case TravelDetailsView(MyTravelsViewModel)
    case CityReviewsDetailsView(CitiesReviewsViewModel)
    case AllReviewsView(CitiesReviewsViewModel)
    case UserPreferencesView
    case WorldExplorationView(DashboardViewModel)
    case GeneralDetailsView(DashboardViewModel)
    case Co2DetailsView(DashboardViewModel)
    case RankingLeaderBoardView(RankingViewModel, String, Bool)
}
