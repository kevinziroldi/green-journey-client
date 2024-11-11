import Combine
import Foundation
import SwiftData

enum SortOption {
    case departureDate
    case price
    case co2Emitted
    case co2CompensationRate
}

class TravelsViewModel: ObservableObject {
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
            
            // sort the new list according to current sort option
            sortTravels()
            // filter according to current filter
            filterTravelDetails()
        }catch {
            
            
            
            // TODO: gestire
            
            
            
            print("Error getting user's travels from SwiftData")
        }
    }
    
    // filters travel details list, selecting only past of future travels
    private func filterTravelDetails() {
        let currentDate = Date()
        filteredTravelDetailsList = travelDetailsList.filter { travel in
            let durationSeconds = Double((travel.segments.last?.duration ?? 0) / 1_000_000_000)
            let departureDateLastSegment = travel.segments.last?.date
            let arrivalDate = departureDateLastSegment?.addingTimeInterval(durationSeconds)
            if showCompleted {
                // select only completed travels
                return (arrivalDate ?? currentDate) <= currentDate
            } else {
                // select only non completed travels
                return (arrivalDate ?? currentDate) > currentDate
            }
        }
    }
    
    // sort travel details list according to some sort option
    private func sortTravels() {
        switch self.sortOption {
        case .departureDate:
            // decreasing departure date
            travelDetailsList.sort {
                let date1 = $0.segments.first?.date ?? Date.distantPast
                let date2 = $1.segments.first?.date ?? Date.distantPast
                return date1 > date2
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
}
