import Combine
import Foundation
import SwiftData
import SwiftUI

// 37.5 kg/€
let co2CompensatedPerEuro = 37.5
// 2 €/Tree
let pricePerTree = 2.0

@MainActor
class MyTravelsViewModel: ObservableObject {
    private let uuid: UUID = UUID()
    
    private var modelContext: ModelContext
    private var serverService: ServerServiceProtocol
    
    // travels lists
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
    
    // selected travel
    @Published var selectedTravel: TravelDetails?
    @Published var compensatedPrice: Int = 0
    @Published var travelReviews: [Review] = []
    
    init(modelContext: ModelContext, serverService: ServerServiceProtocol) {
        self.modelContext = modelContext
        self.serverService = serverService
    }
    
    func getUserTravels() async {
        do {
            let travelDetailsList = try await serverService.getTravels()
            self.travelDetailsList = travelDetailsList
            removeExistingTravels()
            addNewTravels(travelDetailsList: travelDetailsList)
        }catch {
            print("Error fetching travels from server")
            return
        }
    }
    
    private func removeExistingTravels() {
        do {
            let travels = try modelContext.fetch(FetchDescriptor<Travel>())
            let segments = try modelContext.fetch(FetchDescriptor<Segment>())
            
            for travel in travels {
                modelContext.delete(travel)
            }
            for segment in segments {
                modelContext.delete(segment)
            }
            try modelContext.save()
        }catch {
            print("Error deleting old travels from SwiftData: \(error.localizedDescription)")
        }
    }
    
    private func addNewTravels(travelDetailsList: [TravelDetails]) {
        for travelDetails in travelDetailsList {
            modelContext.insert(travelDetails.travel)
            for segment in travelDetails.segments {
                modelContext.insert(segment)
            }
        }
        do {
            try modelContext.save()
        } catch {
            print("Error saving new travels: \(error.localizedDescription)")
        }
    }
    
    func showRequestedTravels() {
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
            for td in travelDetailsList {
                td.sortSegments()
            }
            // sort the new list according to current sort option
            sortTravels()
            // filter according to current filter
            filterTravelDetails()
            
        }catch {
            print("Error getting user's travels from SwiftData")
        }
    }
    
    // filters travel details list, selecting only past of future travels
    private func filterTravelDetails() {
        let currentDate = Date()
        filteredTravelDetailsList = travelDetailsList.filter { travel in
            let lastSegment = travel.getLastSegment()
            if let lastSegment = lastSegment {
                let durationSeconds = Double(lastSegment.duration) / 1_000_000_000
                let departureDateLastSegment = lastSegment.dateTime
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
                if let firstSegment1 = $0.getDepartureSegment() {
                    if let firstSegment2 = $1.getDepartureSegment() {
                        let date1 = firstSegment1.dateTime
                        let date2 = firstSegment2.dateTime
                        
                        if date1 > date2 {
                            return true
                        } else if date1 == date2 && firstSegment1.travelID > firstSegment2.travelID {
                            return true
                        }
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
                if let firstSegment1 = $0.getDepartureSegment() {
                    if let firstSegment2 = $1.getDepartureSegment() {
                        if co2Emitted1 > co2Emitted2 {
                            return true
                        } else if co2Emitted1 == co2Emitted2 && firstSegment1.travelID > firstSegment2.travelID {
                            return true
                        }
                    }
                }
                return false
            }
            
        case .co2CompensationRate:
            // increasing co2 compensated / co2 emitted
            travelDetailsList.sort {
                let co2Emitted1 = $0.segments.reduce(0.0) { $0 + $1.co2Emitted }
                let co2Emitted2 = $1.segments.reduce(0.0) { $0 + $1.co2Emitted }
                let co2Compensated1 = $0.travel.CO2Compensated
                let co2Compensated2 = $1.travel.CO2Compensated
                let isZero1 = co2Emitted1 == 0 && co2Compensated1 == 0
                let isZero2 = co2Emitted2 == 0 && co2Compensated2 == 0
                
                // zero compensated / zero emitted
                if isZero1 && !isZero2 {
                    return false
                }
                if isZero2 && !isZero1 {
                    return true
                }
                if isZero1 && isZero2 {
                    if let travelID1 = $0.travel.travelID {
                        if let travelID2 = $1.travel.travelID {
                            return travelID1 < travelID2
                        } else {
                            return true
                        }
                    } else {
                        return true
                    }
                }
                
                let ratio1 = co2Emitted1 == 0 ? Double.infinity : co2Compensated1 / co2Emitted1
                let ratio2 = co2Emitted2 == 0 ? Double.infinity : co2Compensated2 / co2Emitted2
                
                // increasing ratio
                if ratio1 != ratio2 {
                    return ratio1 < ratio2
                }
                
                // if same ratio, return based on co2 emitted
                if co2Emitted1 != co2Emitted2 {
                    return co2Emitted1 > co2Emitted2
                }
                
                // if all the same, return based on travelID
                if let travelID1 = $0.travel.travelID {
                    if let travelID2 = $1.travel.travelID {
                        return travelID1 < travelID2
                    } else {
                        return true
                    }
                } else {
                    return true
                }
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
                
                if let firstSegment1 = $0.getDepartureSegment() {
                    if let firstSegment2 = $1.getDepartureSegment() {
                        if price1 > price2 {
                            return true
                        } else if price1 == price2 && firstSegment1.travelID > firstSegment2.travelID {
                            return true
                        }
                    }
                }
                return false
            }
        }
    }
    
    func compensateCO2() async {
        let newCo2Compensated = co2CompensatedPerEuro * Double(self.compensatedPrice)
        
        if let selectedTravel = self.selectedTravel {
            let modifiedTravel = Travel(travelCopy: selectedTravel.travel)
            modifiedTravel.CO2Compensated += newCo2Compensated
            
            await updateTravelOnServer(modifiedTravel: modifiedTravel)
            self.compensatedPrice = 0
        } else {
            print("Selected travel is nil")
        }
        
    }
    
    func confirmTravel() async {
        guard let selectedTravel else { return }
        let travel = selectedTravel.travel
        if travel.confirmed {
            print("Travel already confirmed")
            return
        }
        
        let modifiedTravel = Travel(travelCopy: travel)
        modifiedTravel.confirmed = true
        
        await updateTravelOnServer(modifiedTravel: modifiedTravel)
    }
    
    private func updateTravelOnServer(modifiedTravel: Travel) async {
        do {
            let travel = try await serverService.updateTravel(modifiedTravel: modifiedTravel)
            
            // save travel in SwiftData
            await self.updateTravelInSwiftData(updatedTravel: travel)
            // refresh travels
            self.showRequestedTravels()
        }catch {
            print("Error updating travel data: \(error.localizedDescription)")
            return
        }
    }
    
    private func updateTravelInSwiftData(updatedTravel: Travel) async {
        do {
            let travels = try modelContext.fetch(FetchDescriptor<Travel>())
            
            for travel in travels {
                if travel.travelID == updatedTravel.travelID {
                    // update values
                    travel.CO2Compensated = updatedTravel.CO2Compensated
                    travel.confirmed = updatedTravel.confirmed
                    try modelContext.save()
                }
            }
        }catch {
            print("Error while updating travel in SwiftData")
            // refesh travels from server
            await self.getUserTravels()
        }
    }
    
    func deleteTravel() async {
        guard let selectedTravel else { return }
        let travelToDelete = selectedTravel.travel
        do {
            guard let travelID = travelToDelete.travelID else {
                print("Travel id for deletion is nil")
                return
            }
            try await serverService.deleteTravel(travelID: travelID)
            // remove from SwiftData
            await self.deleteTravelFromSwiftData(travelToDelete: travelToDelete)
            // refresh travels
            self.showRequestedTravels()
        }catch {
            print("Error while deletitng")
        }
    }
    
    private func deleteTravelFromSwiftData(travelToDelete: Travel) async {
        if let travelID = travelToDelete.travelID {
            do {
                let travels = try modelContext.fetch(FetchDescriptor<Travel>())
                let segments = try modelContext.fetch(FetchDescriptor<Segment>())
                
                let segmentsByTravelID = Dictionary(grouping: segments, by: { $0.travelID })
                let travelSegments = segmentsByTravelID[travelID]
                
                if let travelSegments = travelSegments {
                    for travel in travels {
                        if travel.travelID == travelToDelete.travelID {
                            modelContext.delete(travel)
                        }
                    }
                    for segment in travelSegments {
                        if segment.travelID == travelToDelete.travelID {
                            modelContext.delete(segment)
                        }
                    }
                    try modelContext.save()
                } else {
                    print("Error computing segments for travel to delete")
                }
            }catch {
                print("Error interacting with SwiftData")
                // refresh data from server
                await self.getUserTravels()
            }
        } else {
            print("Error travel to delete has nil id")
        }
    }
    
    func getNumTrees(_ travel: TravelDetails) -> Int {
        if travel.computeCo2Emitted() == 0 {
            return 0
        }
        return Int(ceil(travel.computeCo2Emitted() / (pricePerTree * co2CompensatedPerEuro)))
    }
    
    func getPlantedTrees(_ travel: TravelDetails) -> Int {
        if travel.travel.CO2Compensated == 0 {
            return 0
        }
        return Int(ceil(travel.travel.CO2Compensated / (pricePerTree * co2CompensatedPerEuro)))
    }
    
}
extension MyTravelsViewModel: Hashable {
    nonisolated static func == (lhs: MyTravelsViewModel, rhs: MyTravelsViewModel) -> Bool {
        return lhs.uuid == rhs.uuid
    }
    
    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
    }
}
