import Foundation

// Головна структура для відповіді поточної погоди
struct CurrentWeatherResponse: Decodable {
    let coord: Coordinates
    let weather: [WeatherCondition] // Масив основних умов (опис, іконка)
    let base: String
    let main: MainWeather       // Об'єкт з температурою та тиском
    let visibility: Int?        // Видимість (метри)
    let wind: Wind?
    let clouds: Clouds?
    let dt: Int                 // Час оновлення даних (Unix timestamp)
    let sys: SystemInfo
    let timezone: Int           // Зсув від UTC у секундах
    let id: Int
    let name: String            // Назва міста, повернута API
    let cod: Int
}
