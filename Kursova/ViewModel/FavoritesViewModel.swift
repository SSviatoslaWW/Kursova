import Foundation
import Combine

/// Manages the list of favorite cities and their persistence.
class FavoritesViewModel: ObservableObject {
    
    @Published var favoriteLocations: [FavoriteLocation] = [] {
        didSet {
            shouldShowEditButton = !favoriteLocations.isEmpty
            saveFavorites()
        }
    }
    
    @Published private(set) var shouldShowEditButton: Bool = false
    
    // ЗМІНЕНО: Новий ключ, щоб уникнути конфліктів зі старим [String]
    private let key = "FavoriteLocationsList_v2"
    
    // MARK: - Initialization
    
    init() {
        loadFavorites()
    }
    
    // MARK: - Public Methods
    
    // ЗМІНЕНО: Логіка перевірки на дублікати
    func addLocation(_ location: FavoriteLocation) {
        
        // ПЕРЕВІРКА ЛИШЕ ЗА ID:
        let alreadyExists = favoriteLocations.contains { $0.id == location.id }
        
        if !alreadyExists {
            favoriteLocations.append(location) // This will trigger `didSet`.
        }
    }
    
    func removeLocation(at offsets: IndexSet) {
        favoriteLocations.remove(atOffsets: offsets)
    }
    
    // ЗМІНЕНО: Завантаження [FavoriteLocation]
    private func loadFavorites() {
        guard let data = UserDefaults.standard.data(forKey: key) else {
            self.favoriteLocations = []
            return
        }
        
        do {
            let loadedLocations = try JSONDecoder().decode([FavoriteLocation].self, from: data)
            self.favoriteLocations = loadedLocations
        } catch {
            print("Failed to decode favorite locations: \(error)")
            self.favoriteLocations = []
        }
    }
    
    // ЗМІНЕНО: Збереження [FavoriteLocation]
    private func saveFavorites() {
        do {
            let data = try JSONEncoder().encode(favoriteLocations)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            print("Failed to encode favorite locations: \(error)")
        }
    }
    
    
    
    
    
}
