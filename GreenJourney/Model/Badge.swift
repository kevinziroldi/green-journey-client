import Foundation

enum Badge: String, Decodable {
    case badgeDistanceLow = "badge_distance_low"
    case badgeDistanceHigh = "badge_distance_high"
    case badgeDistanceMid = "badge_distance_mid"
    
    case badgeEcologicalChoiceLow = "badge_ecological_choice_low"
    case badgeEcologicalChoiceHigh = "badge_ecological_choice_high"
    case badgeEcologicalChoiceMid = "badge_ecological_choice_mid"
    
    case badgeCompensationLow = "badge_compensation_low"
    case badgeCompensationHigh = "badge_compensation_high"
    case badgeCompensationMid = "badge_compensation_mid"
    
    case badgeTravelsNumberLow = "badge_travels_number_low"
    case badgeTravelsNumberHigh = "badge_travels_number_high"
    case badgeTravelsNumberMid = "badge_travels_number_mid"
    
    var baseBadge: String {
        switch self {
        case .badgeDistanceLow, .badgeDistanceMid, .badgeDistanceHigh:
            return "badge_distance_base"
        case .badgeEcologicalChoiceLow, .badgeEcologicalChoiceMid, .badgeEcologicalChoiceHigh:
            return "badge_ecological_choice_base"
        case .badgeCompensationLow, .badgeCompensationMid, .badgeCompensationHigh:
            return "badge_compensation_base"
        case .badgeTravelsNumberLow, .badgeTravelsNumberMid, .badgeTravelsNumberHigh:
            return "badge_travels_number_base"
        }
    }
    
    static var allTypes: [[Badge]] {
        [
            [.badgeDistanceLow, .badgeDistanceMid, .badgeDistanceHigh],
            [.badgeEcologicalChoiceLow, .badgeEcologicalChoiceMid, .badgeEcologicalChoiceHigh],
            [.badgeCompensationLow, .badgeCompensationMid, .badgeCompensationHigh],
            [.badgeTravelsNumberLow, .badgeTravelsNumberMid, .badgeTravelsNumberHigh]
        ]
    }
}
