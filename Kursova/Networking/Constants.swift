// Constants.swift

import Foundation
// ⬅️ Обов'язковий імпорт: Надає доступ до базових типів Swift, таких як URL.

/// Структура, що зберігає всі статичні (незмінні) константи, необхідні для роботи з OpenWeatherMap API.
struct Constants {
    
    // MARK: - API Connection Details
    
    // 🛑 Базова URL для всіх запитів до API (current weather, forecast)
    static let baseURL = "https://api.openweathermap.org/data/2.5/"
    
    // 🔑 Унікальний ключ доступу до OpenWeatherMap, отриманий під час реєстрації.
    static let apiKey = "52a11ec7b3324b99fad034c62a80c731"
    
    // 🌡️ Одиниці виміру: "metric" забезпечує температуру в Цельсіях (°C).
    static let units = "metric"
    
    // MARK: - Utility Functions
    
    /// Функція для формування повного URL-адреси до зображення іконки погоди.
    /// - Parameter iconCode: Код іконки, отриманий з JSON-відповіді API (наприклад, "04d").
    /// - Returns: Опціональний URL для завантаження зображення.
    static func iconURL(iconCode: String) -> URL? {
        // Формуємо повний URL для завантаження іконки у високій якості (@2x).
        return URL(string: "https://openweathermap.org/img/wn/\(iconCode)@2x.png")
    }
}
