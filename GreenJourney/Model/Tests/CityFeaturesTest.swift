import Testing

@testable import GreenJourney

struct CityFeaturesTest {
    @Test
    func testInitializerWithAttributes() {
        let city = CityFeatures(
            id: 55,
            iata: "PAR",
            countryCode: "FR",
            cityName: "Paris",
            countryName: "France",
            population: 11060000.0,
            capital: true,
            averageTemperature: 22.0219696969697,
            continent: "Europe",
            livingCost: 3.664,
            travelConnectivity: 10.0,
            safety: 6.2465,
            healthcare: 8.207666666666666,
            education: 7.085,
            economy: 4.2045,
            internetAccess: 9.716,
            outdoors: 4.433
        )
        
        #expect(city.id == 55)
        #expect(city.iata == "PAR")
        #expect(city.countryCode == "FR")
        #expect(city.cityName == "Paris")
        #expect(city.countryName == "France")
        #expect(city.population == 11060000.0)
        #expect(city.capital == true)
        #expect(city.averageTemperature == 22.0219696969697)
        #expect(city.continent == "Europe")
        #expect(city.livingCost == 3.664)
        #expect(city.travelConnectivity == 10.0)
        #expect(city.safety == 6.2465)
        #expect(city.healthcare == 8.207666666666666)
        #expect(city.education == 7.085)
        #expect(city.economy == 4.2045)
        #expect(city.internetAccess == 9.716)
        #expect(city.outdoors == 4.433)
    }
}
