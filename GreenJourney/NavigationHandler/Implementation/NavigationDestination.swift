enum NavigationDestination: Hashable {
    case LoginView
    case SignupView(AuthenticationViewModel)
    case EmailVerificationView(AuthenticationViewModel)
    case OutwardOptionsView(TravelSearchViewModel)
    case ReturnOptionsView(TravelSearchViewModel)
    case TravelDetailsView(MyTravelsViewModel)
    case CityReviewsDetailsView(CitiesReviewsViewModel)
    case AllReviewsView(CitiesReviewsViewModel)
}
