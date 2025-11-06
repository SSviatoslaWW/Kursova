import Foundation

// Головна структура для відповіді прогнозу
struct ForecastResponse: Decodable {
    let list: [ForecastItem] // Масив 3-годинних прогнозів
}
