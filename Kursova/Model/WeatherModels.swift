// Model/WeatherModels.swift

import Foundation

// =================================================================
// MARK: - 1. СТРУКТУРИ ДЛЯ ПОТОЧНОЇ ПОГОДИ (API /weather)
// =================================================================

struct Coordinates: Decodable {
    let lon: Double // Довгота
    let lat: Double // Широта
}
struct Wind: Decodable {
    let speed: Double? // Швидкість вітру
    let deg: Int?      // Напрямок вітру (градуси)
}
struct Clouds: Decodable {
    let all: Int // Хмарність у відсотках
}
struct SystemInfo: Decodable {
    let country: String // Код країни
    let sunrise: Int    // Час сходу сонця
    let sunset: Int     // Час заходу сонця
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
    
    // Обчислювана властивість: Температура, округлена до цілого, з °C
    var temperatureString: String {
        return String(format: "%.0f°C", temp)
    }
}


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


// Структура для погодних умов
struct WeatherCondition: Decodable {
    let main: String        // Основна група (Clear, Rain, Snow) - для логіки градієнта
    let description: String // Детальний опис
    let icon: String        // Код іконки
    
    // Обчислювана властивість для формування URL іконки
    var iconURL: URL? {
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
    
    //Повна назва дня (використовується у модальному вікні)
    var fullDayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE" // Формат: Понеділок
        formatter.locale = Locale(identifier: "uk_UA")
        return formatter.string(from: date).capitalized
    }

    // 🛑 dayOfWeekShort: Скорочена назва дня (використовується для карток 5-денного прогнозу)
    var dayOfWeekShort: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE" // Формат: Пн, Вт
        formatter.locale = Locale(identifier: "uk_UA")
        
        return formatter.string(from: date).capitalized
    }
}
