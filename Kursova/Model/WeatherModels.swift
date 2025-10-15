// Model/WeatherModels.swift

import Foundation

// MARK: - Допоміжні Структури для CurrentWeatherResponse

struct Coordinates: Decodable {
    let lon: Double
    let lat: Double
}
struct Wind: Decodable {
    let speed: Double?
    let deg: Int?
}
struct Clouds: Decodable {
    let all: Int
}
struct SystemInfo: Decodable {
    let country: String
    let sunrise: Int
    let sunset: Int
}

// MARK: - CurrentWeatherResponse

struct CurrentWeatherResponse: Decodable {
    let coord: Coordinates
    let weather: [WeatherCondition]
    let base: String
    let main: MainWeather
    let visibility: Int?
    let wind: Wind?
    let clouds: Clouds?
    let dt: Int
    let sys: SystemInfo
    let timezone: Int
    let id: Int
    let name: String
    let cod: Int
}

struct MainWeather: Decodable {
    let temp: Double
    let tempMin: Double
    let tempMax: Double
    let humidity: Int
    let pressure: Int
    
    enum CodingKeys: String, CodingKey {
        case temp, humidity, pressure
        case tempMin = "temp_min"
        case tempMax = "temp_max"
    }
    
    var temperatureString: String {
        return String(format: "%.0f°C", temp)
    }
}

struct WeatherCondition: Decodable {
    let main: String
    let description: String
    let icon: String
    
    var iconURL: URL? {
        Constants.iconURL(iconCode: icon)
    }
}

// MARK: - Структури для Forecast

struct ForecastResponse: Decodable {
    let list: [ForecastItem]
}

struct ForecastItem: Decodable {
    let dt: Int
    let main: MainWeather
    let weather: [WeatherCondition]
    
    // 🛑 ДОДАНО: Обчислювані властивості для дати та дня тижня
    var date: Date {
        Date(timeIntervalSince1970: TimeInterval(dt))
    }
    
    var dayOfWeek: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date).capitalized
    }
}
