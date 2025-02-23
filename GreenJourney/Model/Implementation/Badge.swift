import Foundation

enum Badge: String, Encodable, Decodable {
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
    
    case badgeDistanceBase = "badge_distance_base"
    case badgeEcologicalChoiceBase = "badge_ecological_choice_base"
    case badgeCompensationBase = "badge_compensation_base"
    case badgeTravelsNumberBase = "badge_travels_number_base"
    
    var baseBadge: Badge {
        switch self {
        case .badgeDistanceLow, .badgeDistanceMid, .badgeDistanceHigh:
            return Badge.badgeDistanceBase
        case .badgeEcologicalChoiceLow, .badgeEcologicalChoiceMid, .badgeEcologicalChoiceHigh:
            return Badge.badgeEcologicalChoiceBase
        case .badgeCompensationLow, .badgeCompensationMid, .badgeCompensationHigh:
            return Badge.badgeCompensationBase
        case .badgeTravelsNumberLow, .badgeTravelsNumberMid, .badgeTravelsNumberHigh:
            return Badge.badgeTravelsNumberBase
        default:
            return self
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
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        // if base badge, don't send to server
        switch self {
        case .badgeDistanceBase, .badgeEcologicalChoiceBase, .badgeCompensationBase, .badgeTravelsNumberBase:
            // Ad esempio, codifica come stringa vuota oppure potresti decidere di non includere affatto il campo nel JSON
            try container.encode("")
        default:
            try container.encode(self.rawValue)
        }
    }
}
