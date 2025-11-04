// Model/WeatherModels.swift

import Foundation
import CoreLocation

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
    
    
    // Перетворює градуси (0-360) на напрямок (Пн, Сх, Пд, Зх)
    var directionShort: String {
        guard let deg = deg else { return "—" }
        
        let directions = ["Пн", "ПнСх", "Сх", "ПдСх", "Пд", "ПдЗх", "Зх", "ПнЗх"]
        let index = Int((Double(deg) + 22.5) / 45.0) & 7
        return directions[index]
    }
    
    // Обчислювана властивість для відображення швидкості
    var speedString: String {
        guard let speed = speed else { return "—" }
        return String(format: "%.1f м/с", speed)
    }
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
    let main: String        // Основна група (Clear, Rain, Snow) - для логіки фону
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
    let wind: Wind?
    
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
    
    //Скорочена назва дня (використовується для карток 5-денного прогнозу)
    var dayOfWeekShort: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE" // Формат: Пн, Вт
        formatter.locale = Locale(identifier: "uk_UA")
        
        return formatter.string(from: date).capitalized
    }
    
    //Скорочена дата 24 жовт
    var shortDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        formatter.locale = Locale(identifier: "uk_UA")
        return formatter.string(from: date)
    }
}



// Зберігає всі дані про улюблене місце
// 'Identifiable' та 'Equatable' тепер працюють на 'id'
struct FavoriteLocation: Codable, Identifiable, Equatable {
    
    /// Унікальний ID міста з API OpenWeatherMap (напр. 703448 для Києва)
    let id: Int
    
    let name: String
    let country: String // Повна назва країни
    let lat: Double
    let lon: Double
    
    // Перевірка на рівність (використовується для .onChange)
    static func == (lhs: FavoriteLocation, rhs: FavoriteLocation) -> Bool {
        return lhs.id == rhs.id
    }
}
