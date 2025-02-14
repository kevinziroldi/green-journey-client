enum ServerServiceError: Error {
    case saveUserFailed
    case getUserFailed
    case modifyUserFailed
    case getRankingFailed
    case getReviewsCityFailed
    case getBestReviewsFailed
    case uploadReviewFailed
    case modifyReviewFailed
    case deleteReviewFailed
    case computeRoutesFailed
    case saveTravelFailed
    case getTravelsFailed
    case deleteTravelFailed
    case modifyTravelFailed
}
