// Model/WeatherModels.swift

import Foundation

// =================================================================
// MARK: - 1. СТРУКТУРИ ДЛЯ ПОТОЧНОЇ ПОГОДИ (API /weather)
// =================================================================

// Допоміжні структури для декодування вкладених об'єктів JSON

struct Coordinates: Decodable {
    let lon: Double // Довгота
    let lat: Double // Широта
}
struct Wind: Decodable {
    let speed: Double? // Швидкість вітру
    let deg: Int?      // Напрямок вітру
}
struct Clouds: Decodable {
    let all: Int // Хмарність у відсотках
}
struct SystemInfo: Decodable {
    let country: String // Код країни (наприклад, UA)
    let sunrise: Int    // Час сходу сонця (Unix timestamp)
    let sunset: Int     // Час заходу сонця (Unix timestamp)
}

// Головна структура для відповіді поточної погоди
struct CurrentWeatherResponse: Decodable {
    let coord: Coordinates
    let weather: [WeatherCondition] // Масив з основними умовами та іконкою
    let base: String
    let main: MainWeather       // Об'єкт з температурою та тиском
    let visibility: Int?
    let wind: Wind?
    let clouds: Clouds?
    let dt: Int                 // Час оновлення даних (Unix timestamp)
    let sys: SystemInfo
    let timezone: Int
    let id: Int
    let name: String            // Назва міста, повернута API
    let cod: Int
}

// Структура для основних параметрів (Main)
struct MainWeather: Decodable {
    let temp: Double    // Поточна температура (°C)
    let tempMin: Double // Мінімальна температура
    let tempMax: Double // Максимальна температура
    let humidity: Int   // Вологість (%)
    let pressure: Int   // Тиск (гПа)
    
    // Кодування для відповідності snake_case у JSON
    enum CodingKeys: String, CodingKey {
        case temp, humidity, pressure
        case tempMin = "temp_min"
        case tempMax = "temp_max"
    }
    
    // Обчислювана властивість для форматування температури
    var temperatureString: String {
        return String(format: "%.0f°C", temp)
    }
}

// Структура для погодних умов (WeatherCondition)
struct WeatherCondition: Decodable {
    let main: String        // Основна група (Clear, Rain, Snow) - використовується для градієнта
    let description: String // Детальний опис
    let icon: String        // Код іконки
    
    // Обчислювана властивість для формування URL іконки
    var iconURL: URL? {
        // Примітка: Потрібен доступ до Constants.iconURL
        Constants.iconURL(iconCode: icon)
    }
}

// =================================================================
// MARK: - 2. СТРУКТУРИ ДЛЯ ПРОГНОЗУ (API /forecast)
// =================================================================

// Головна структура для відповіді прогнозу
struct ForecastResponse: Decodable {
    let list: [ForecastItem] // Масив 3-годинних прогнозів
}

// Структура для одного запису прогнозу (один 3-годинний інтервал)
struct ForecastItem: Decodable {
    let dt: Int             // Час прогнозу (Unix timestamp)
    let main: MainWeather   // Температурні дані для цього інтервалу
    let weather: [WeatherCondition] // Погодні умови для цього інтервалу
    
    // Обчислювана властивість: конвертація Unix timestamp у Date
    var date: Date {
        Date(timeIntervalSince1970: TimeInterval(dt))
    }
    
    // 🛑 fullDayName: Повна назва дня для детального модального вікна
    var fullDayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE" // Формат: Понеділок, Вівторок
        formatter.locale = Locale(identifier: "uk_UA")
        return formatter.string(from: date).capitalized
    }
}
