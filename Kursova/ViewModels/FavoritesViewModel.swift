import Foundation
import Combine

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
    
    //Додавання нового міста
    func addLocation(_ location: FavoriteLocation) {
        print("All the location favorites \(favoriteLocations)")
        print("-----------------------------------------------")
        if let index = favoriteLocations.firstIndex(of: location) {
            print("Remove Item at index \(index)")
            print(favoriteLocations[index])
            favoriteLocations.remove(at: index)
        } else {
            print("Add location \(location)")
            favoriteLocations.append(location)
        }
    }
    
    
    //видалення зі списку
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
