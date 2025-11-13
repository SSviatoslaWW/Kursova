import Foundation

// Зберігає всі дані про улюблене місце
struct FavoriteLocation: Codable, Identifiable, Equatable {
    
    let id: Int
    let name: String
    let country: String 
    let lat: Double
    let lon: Double
    
    // Перевірка на рівність (використовується для .onChange)
    static func == (lhs: FavoriteLocation, rhs: FavoriteLocation) -> Bool {
        return lhs.id == rhs.id
    }
}
