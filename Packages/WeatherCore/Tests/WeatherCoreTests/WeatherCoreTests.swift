import Testing
@testable import WeatherCore

struct WeatherServiceTests {
    private let sut: WeatherService

    init() {
        self.sut = WeatherService()
    }

    @Test
    func example() async throws {
        let _ = try await self.sut.getForecasts(for: .estonian)
    }
}
