import Combine
import Foundation
import SwiftData

enum SortOption {
    case departureDate
    case price
    case co2Emitted
    case co2CompensationRate
}

class MyTravelsViewModel: ObservableObject {
    private var modelContext: ModelContext
    var travelDetailsList: [TravelDetails] = []
    @Published var filteredTravelDetailsList: [TravelDetails] = []
    @Published var showCompleted = true {
        didSet {
            // already sorted
            // filter according to new filter
            filterTravelDetails()
        }
    }
    @Published var sortOption = SortOption.departureDate {
        didSet {
            // sort according to new sort option
            sortTravels()
            // same filter, but call to show
            filterTravelDetails()
        }
    }
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func getUserTravels() {
        do {
            let travels = try modelContext.fetch(FetchDescriptor<Travel>())
            let segments = try modelContext.fetch(FetchDescriptor<Segment>())
            
            let segmentsByTravelID = Dictionary(grouping: segments, by: { $0.travelID })
            travelDetailsList = travels.compactMap { travel in
                if let travelID = travel.travelID {
                    if let travelSegments = segmentsByTravelID[travelID] {
                        return TravelDetails(travel: travel, segments: travelSegments)
                    } else {
                        return TravelDetails(travel: travel, segments: [])
                    }
                }
                return nil
            }
            
            // sort segments for every travel
            sortSegments()
            // sort the new list according to current sort option
            sortTravels()
            // filter according to current filter
            filterTravelDetails()
            
        }catch {
            
            
            
            // TODO: gestire
            
            
            
            print("Error getting user's travels from SwiftData")
        }
    }
    
    // sort segments for all travels
    private func sortSegments() {
        for td in travelDetailsList {
            td.segments.sort {
                let numSegment1 = $0.numSegment
                let numSegment2 = $1.numSegment
                return numSegment1 < numSegment2
            }
        }
    }
    
    // filters travel details list, selecting only past of future travels
    private func filterTravelDetails() {
        let currentDate = Date()
        filteredTravelDetailsList = travelDetailsList.filter { travel in
            let lastSegment = travel.getLastSegment()
            if let lastSegment = lastSegment {
                let durationSeconds = Double(lastSegment.duration) / 1_000_000_000
                let departureDateLastSegment = lastSegment.date
                let arrivalDate = departureDateLastSegment.addingTimeInterval(durationSeconds)
                
                if showCompleted {
                    // select only completed travels
                    return arrivalDate <= currentDate
                } else {
                    // select only non completed travels
                    return arrivalDate > currentDate
                }
            }
            // nothing to sort
            return false
        }
    }
   
    // sort travel details list according to some sort option
    private func sortTravels() {
        switch self.sortOption {
        case .departureDate:
            // decreasing departure date
            travelDetailsList.sort {
                if let firstSegment1 = $0.getFirstSegment() {
                    if let firstSegment2 = $1.getFirstSegment() {
                        let date1 = firstSegment1.date
                        let date2 = firstSegment2.date
                        return date1 > date2
                    }
                }
                return false
            }
        case .co2Emitted:
            // decreasing co2 emitted
            travelDetailsList.sort {
                var co2Emitted1 = 0.0
                for segment in $0.segments {
                    co2Emitted1 += segment.co2Emitted
                }
                var co2Emitted2 = 0.0
                for segment in $1.segments {
                    co2Emitted2 += segment.co2Emitted
                }
                return co2Emitted1 > co2Emitted2
            }
        case .co2CompensationRate:
            // increasing co2 compensated / co2 emitted
            travelDetailsList.sort {
                var co2Emitted1 = 0.0
                for segment in $0.segments {
                    co2Emitted1 += segment.co2Emitted
                }
                var co2Emitted2 = 0.0
                for segment in $1.segments {
                    co2Emitted2 += segment.co2Emitted
                }
                let co2Compensated1 = $0.travel.CO2Compensated
                let co2Compensated2 = $1.travel.CO2Compensated
                return co2Compensated1/co2Emitted1 < co2Compensated2/co2Emitted2
            }
        case .price:
            // decreasing price
            travelDetailsList.sort {
                var price1 = 0.0
                for segment in $0.segments {
                    price1 += segment.price
                }
                var price2 = 0.0
                for segment in $1.segments {
                    price2 += segment.price
                }
                return price1 > price2
            }
        }
    }
    
    func compensateCO2(travelID: Int, priceCompensated: Float) {
        
        // TODO
        // compute CO2 compensated
        let co2Compensated = 0  // TODO change
    
        // get travel
        
        let fetchDescriptor = FetchDescriptor<Travel>(
            predicate: #Predicate { $0.travelID == travelID }
        )
        do {
            let travel = try modelContext.fetch(fetchDescriptor)
            
            // update CO2 compensated in server
            
            // if response ok, update CO2 compensated in SwiftData
            
        }catch {
            
            
            // TODO
            print("Error fecthing travel from SwiftData")
            
            
        }
    }
}
