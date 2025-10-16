// Networking/APIError.swift

import Foundation // ⬅️ ВИПРАВЛЕННЯ 1: Обов'язковий імпорт для Error, LocalizedError

enum APIError: Error, LocalizedError, Equatable { // ⬅️ Оголошуємо протоколи
    case invalidURL
    case cityNotFound
    case decodingError
    case noData
    case other(String) // ⬅️ Випадок з асоційованим значенням
    
    // 🛑 ВИПРАВЛЕННЯ 2: Явна реалізація Equatable для порівняння other(String)
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
