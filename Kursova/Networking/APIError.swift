import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case cityNotFound
    case decodingError
    case noData
    case other(String)
    
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
