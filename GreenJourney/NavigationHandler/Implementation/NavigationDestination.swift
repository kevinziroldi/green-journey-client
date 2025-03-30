enum NavigationDestination: Hashable {
    case LoginView
    case SignupView(AuthenticationViewModel)
    case EmailVerificationView(AuthenticationViewModel)
    case OutwardOptionsView(String, String, TravelSearchViewModel)
    case ReturnOptionsView(String, String, TravelSearchViewModel)
    case TravelDetailsView(MyTravelsViewModel)
    case CityReviewsDetailsView(CitiesReviewsViewModel)
    case AllReviewsView(CitiesReviewsViewModel)
    case UserPreferencesView
}
