import Foundation


struct UtilitiesFunctions {
    
    static func convertTotalDurationToString(totalDuration: Int) -> String {
        var hours: Int = 0
        var minutes: Int = 0
        var days: Int = 0
        var months: Int = 0
        var years: Int = 0
        
        // 1 hour = 3600 seconds
        hours = totalDuration / (3600)
        let remainingSeconds = (totalDuration) % (3600)
        minutes = remainingSeconds / 60
        while (hours >= 24) {
            days += 1
            hours -= 24
        }
        while (days >= 30) {
            months += 1
            days -= 30
        }
        while (months >= 12) {
            years += 1
            months -= 12
        }
        if years > 0 {
            return "\(years) y, \(months) m, \(days) d, \(hours) h, \(minutes) min"
        }
        if years == 0 && months > 0 {
            return "\(months) m, \(days) d, \(hours) h, \(minutes) min"
        }
        if months == 0 && days > 0 {
            return "\(days) d, \(hours) h, \(minutes) min"
        }
        return "\(hours) h, \(minutes) min"
        
    }
}
