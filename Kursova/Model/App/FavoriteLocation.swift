import Foundation

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
