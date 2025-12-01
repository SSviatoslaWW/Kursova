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
    
    // ключ по якому зберігаються дані
    private let key = "FavoriteLocationsList_v2"
    
    // MARK: - Initialization
    
    init() {
        loadFavorites()
    }
    
    // MARK: - Public Methods
    
    //Додавання нового міста
    func addLocation(_ location: FavoriteLocation) {
        
        if let index = favoriteLocations.firstIndex(where: {
            // Місто вважається однаковим, якщо збігається назва і країна
            $0.name.caseInsensitiveCompare(location.name) == .orderedSame &&
            $0.country.caseInsensitiveCompare(location.country) == .orderedSame
        }) {
            // Місто вже є у списку → видаляємо
            favoriteLocations.remove(at: index)
        } else {
            // Додаємо нове місто
            favoriteLocations.append(location)
        }
    }
    
    
    
    func removeLocation(at offsets: IndexSet) {
        favoriteLocations.remove(atOffsets: offsets)
    }
    
    //Завантаження [FavoriteLocation]
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
    
    //Збереження [FavoriteLocation]
    private func saveFavorites() {
        do {
            let data = try JSONEncoder().encode(favoriteLocations)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            print("Failed to encode favorite locations: \(error)")
        }
    }
}
