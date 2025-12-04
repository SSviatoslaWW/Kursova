import Foundation

struct Wind: Decodable {
    let speed: Double? // Швидкість вітру
    let deg: Int?      // Напрямок вітру (градуси)
    
    // Перетворює градуси (0-360) на напрямок (Пн, Сх, Пд, Зх)
    var directionShort: String {
        guard let deg = deg else { return "—" }
        
        let directions = ["Пн", "ПнСх", "Сх", "ПдСх", "Пд", "ПдЗх", "Зх", "ПнЗх"]
        // Використання бітового AND для безпечного взяття індексу по модулю 8
        let index = Int((Double(deg) + 22.5) / 45.0) & 7
        return directions[index]
    }
    
    // Обчислювана властивість для відображення швидкості
    var speedString: String {
        guard let speed = speed else { return "—" }
        return String(format: "%.1f м/с", speed)
    }
}
