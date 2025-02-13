import Testing

@testable import GreenJourney

struct CityCompleterDatasetTest {
    @Test
    func testEmptyInitializer() {
        let city = CityCompleterDataset()
        
        #expect(city.cityName == "")
        #expect(city.countryName == "")
        #expect(city.continent == "")
        #expect(city.countryCode == "")
        #expect(city.iata == "")
    }
    
    @Test
    func testInitializerWithAttributes() {
        let city = CityCompleterDataset(
            cityName: "Paris",
            countryName: "France",
            iata: "PAR",
            countryCode: "FR",
            continent: "Europe"
        )
        
        #expect(city.cityName == "Paris")
        #expect(city.countryName == "France")
        #expect(city.iata == "PAR")
        #expect(city.countryCode == "FR")
        #expect(city.continent == "Europe")
    }
    
    @Test
    func testCopyInitializer() {
        let city = CityCompleterDataset(
            cityName: "Paris",
            countryName: "France",
            iata: "PAR",
            countryCode: "FR",
            continent: "Europe"
        )
        
        let copyCity = CityCompleterDataset(existingCity: city)
        
        #expect(city.cityName == copyCity.cityName)
        #expect(city.countryName == copyCity.countryName)
        #expect(city.iata == copyCity.iata)
        #expect(city.countryCode == copyCity.countryCode)
        #expect(city.cityName == copyCity.cityName)
    }
    
    @Test
    func testEquality() {
        let cityParis1 = CityCompleterDataset(
            cityName: "Paris",
            countryName: "France",
            iata: "PAR",
            countryCode: "FR",
            continent: "Europe"
        )
        let cityParis2 = CityCompleterDataset(
            cityName: "Paris",
            countryName: "France",
            iata: "PAR",
            countryCode: "FR",
            continent: "Europe"
        )
        #expect(cityParis1 == cityParis2)
    }
    
    @Test
    func testInequality() {
        let cityParis = CityCompleterDataset(
            cityName: "Paris",
            countryName: "France",
            iata: "PAR",
            countryCode: "FR",
            continent: "Europe"
        )
        let cityMilan = CityCompleterDataset(
            cityName: "Milan",
            countryName: "Italy",
            iata: "MIL",
            countryCode: "IT",
            continent: "Europe"
        )
        #expect(cityParis != cityMilan)
    }
    
}
