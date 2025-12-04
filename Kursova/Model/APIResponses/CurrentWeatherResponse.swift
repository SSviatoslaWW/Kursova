import Foundation

// Головна структура для відповіді поточної погоди
struct CurrentWeatherResponse: Decodable {
    let coord: Coordinates
    let weather: [WeatherCondition] // Масив основних умов (опис, іконка)
    let main: MainWeather       // Об'єкт з температурою та тиском
    let visibility: Int?        // Видимість (метри)
    let wind: Wind?
    let sys: SystemInfo
    let id: Int
    let name: String            // Назва міста, повернута API
    let cod: Int
}
