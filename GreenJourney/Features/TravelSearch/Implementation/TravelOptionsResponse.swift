struct TravelOptionsResponse: Decodable {
    let options: [[Segment]]
    
    enum CodingKeys: String, CodingKey {
        case options = "options"
    }
}
