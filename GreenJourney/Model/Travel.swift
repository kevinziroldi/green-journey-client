import Foundation //to use Date type

class Travel: Decodable {
    var travelID: Int
    var departure: String
    var destination: String
    var startDate: Date
    var endDate: Date
    var vehivle: String   //will be replaced with an enum
    var CO2Emitted: Float64 {
        return computeCO2(from: departure, to: destination)
    }
    var CO2Compensated: Float64
    var IDUser: Int
    var IsDone: Bool
    
    func computeCO2(from departure: String, to destination: String) -> Float64 {
        var co2Emitted: Float64 //TODO
        co2Emitted = 12.3
        return co2Emitted
    }
    
    init(travelID: Int, departure: String, destination: String, startDate: Date, endDate: Date, vehivle: String, CO2Compensated: Float64, IDUser: Int, IsDone: Bool) {
        self.travelID = travelID
        self.departure = departure
        self.destination = destination
        self.startDate = startDate
        self.endDate = endDate
        self.vehivle = vehivle
        self.CO2Compensated = CO2Compensated
        self.IDUser = IDUser
        self.IsDone = IsDone
    }
}
