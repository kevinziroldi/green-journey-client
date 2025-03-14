import Testing

@testable import GreenJourney

struct BadgeUnitTest {
    @Test
    func testBaseBadgeDistance() {
        #expect(Badge.badgeDistanceLow.baseBadge == Badge.badgeDistanceBase)
        #expect(Badge.badgeDistanceMid.baseBadge == Badge.badgeDistanceBase)
        #expect(Badge.badgeDistanceHigh.baseBadge == Badge.badgeDistanceBase)
    }
    
    @Test
    func testBaseBadgeEcologicalChoice() {
        #expect(Badge.badgeEcologicalChoiceLow.baseBadge == Badge.badgeEcologicalChoiceBase)
        #expect(Badge.badgeEcologicalChoiceMid.baseBadge == Badge.badgeEcologicalChoiceBase)
        #expect(Badge.badgeEcologicalChoiceHigh.baseBadge == Badge.badgeEcologicalChoiceBase)
    }
    
    @Test
    func testBaseBadgeCompensation() {
        #expect(Badge.badgeCompensationLow.baseBadge == Badge.badgeCompensationBase)
        #expect(Badge.badgeCompensationMid.baseBadge == Badge.badgeCompensationBase)
        #expect(Badge.badgeCompensationHigh.baseBadge == Badge.badgeCompensationBase)
    }
    
    @Test
    func testBaseBadgeTravelsNumber() {
        #expect(Badge.badgeTravelsNumberLow.baseBadge == Badge.badgeTravelsNumberBase)
        #expect(Badge.badgeTravelsNumberMid.baseBadge == Badge.badgeTravelsNumberBase)
        #expect(Badge.badgeTravelsNumberHigh.baseBadge == Badge.badgeTravelsNumberBase)
    }
    
    @Test
    func testBaseBadgeBase() {
        #expect(Badge.badgeDistanceBase == Badge.badgeDistanceBase)
        #expect(Badge.badgeEcologicalChoiceBase == Badge.badgeEcologicalChoiceBase)
        #expect(Badge.badgeCompensationBase == Badge.badgeCompensationBase)
        #expect(Badge.badgeTravelsNumberBase == Badge.badgeTravelsNumberBase)
    }
    
    @Test
    func testAllTypes() {
        let groups = Badge.allTypes
        #expect(groups.count == 4)
        
        for group in groups {
            #expect(group.count == 3)
        }
        
        let distanceGroup = groups[0]
        #expect(distanceGroup.contains(.badgeDistanceLow))
        #expect(distanceGroup.contains(.badgeDistanceMid))
        #expect(distanceGroup.contains(.badgeDistanceHigh))
        
        let ecologicalGroup = groups[1]
        #expect(ecologicalGroup.contains(.badgeEcologicalChoiceLow))
        #expect(ecologicalGroup.contains(.badgeEcologicalChoiceMid))
        #expect(ecologicalGroup.contains(.badgeEcologicalChoiceHigh))
        
        let compensationGroup = groups[2]
        #expect(compensationGroup.contains(.badgeCompensationLow))
        #expect(compensationGroup.contains(.badgeCompensationMid))
        #expect(compensationGroup.contains(.badgeCompensationHigh))
        
        let travelsNumberGroup = groups[3]
        #expect(travelsNumberGroup.contains(.badgeTravelsNumberLow))
        #expect(travelsNumberGroup.contains(.badgeTravelsNumberMid))
        #expect(travelsNumberGroup.contains(.badgeTravelsNumberHigh))
    }
}
