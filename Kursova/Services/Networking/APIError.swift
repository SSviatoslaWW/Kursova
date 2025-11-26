// Networking/APIError.swift

import Foundation

enum APIError: Error, LocalizedError, Equatable {
    
    case invalidURL     // Помилка при формуванні URL.
    case cityNotFound   // Код 404: Місто не знайдено в базі даних API.
    case decodingError  // Помилка парсингу JSON (структура моделі не збігається з даними).
    case noData         // Дані не були отримані (наприклад, відповідь сервера була порожньою).
    case other(String)  // Інша невідома мережева помилка (з асоційованим повідомленням).
    
    
    static func == (lhs: APIError, rhs: APIError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL), (.cityNotFound, .cityNotFound), (.decodingError, .decodingError), (.noData, .noData):
            return true
        case let (.other(l), .other(r)):
            return l == r
        default:
            return false
        }
    }
    
    /// Повертає опис помилки, зручний для відображення користувачу.
    var errorDescription: String? {
        switch self {
        case .cityNotFound: return "Місто не знайдено. Перевірте назву."
        case .decodingError: return "Помилка обробки даних сервера."
        case .invalidURL: return "Некоректний URL запит."
        case .noData: return "Не отримано даних."
        case .other(let msg): return "Мережева помилка: \(msg)"
        }
    }
}
