import Foundation

// Головна структура для відповіді поточної погоди
struct CurrentWeatherResponse: Decodable {
    let coord: Coordinates
    let weather: [WeatherCondition] // Масив основних умов
    let main: MainWeather       // Об'єкт з температурою та тиском
    let visibility: Int?        // Видимість
    let wind: Wind?
    let sys: SystemInfo
    let id: Int
    let name: String 
    let cod: Int
}
