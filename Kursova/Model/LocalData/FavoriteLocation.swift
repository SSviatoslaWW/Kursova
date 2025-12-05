import Foundation

// Зберігає всі дані про улюблене місце
struct FavoriteLocation: Codable, Identifiable, Equatable {
    
    let id: Int
    let name: String
    let country: String
    let lat: Double
    let lon: Double
    
    var uid: String {
        return "\(id)-\(lat)-\(lon)"
    }
    
    // Перевизначаємо стандартне порівняння "=="
    static func == (lhs: FavoriteLocation, rhs: FavoriteLocation) -> Bool {
        
        // 1. Перевірка ID
        // Це база. Якщо ID різні — це точно різні місця.
        // Але якщо ID однакові (як у Белза і Хлівчан), йдемо далі.
        let idMatch = lhs.id == rhs.id
        
        // 2. Перевірка координат (Фізична відстань)
        // Рахуємо різницю між широтою та довготою
        let latDiff = abs(lhs.lat - rhs.lat)
        let lonDiff = abs(lhs.lon - rhs.lon)
        
        // Допускаємо похибку 0.05 градуса (це приблизно 5 км).
        // Якщо відстань менша — це те саме місце.
        // Якщо відстань більша (навіть при однаковому ID) — це різні села.
        let isNearby = latDiff < 0.05 && lonDiff < 0.05
        
        // 3. Фінальний результат
        // Місця рівні ТІЛЬКИ якщо збігається ID *І* вони знаходяться поруч.
        return idMatch && isNearby
    }
}
