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
        
        let idMatch = lhs.id == rhs.id
        
        let latDiff = abs(lhs.lat - rhs.lat)
        let lonDiff = abs(lhs.lon - rhs.lon)
        
        let isNearby = latDiff < 0.05 && lonDiff < 0.05
        
        return idMatch && isNearby
    }
}
