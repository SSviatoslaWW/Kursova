
import Foundation
import Combine

class FavoritesViewModel: ObservableObject {
    @Published var favoriteCities: [String] = []
    private let key = "FavoriteCitiesList"
    
    init() {
        loadFavorites()
    }
    
    private func loadFavorites() {
        if let savedCities = UserDefaults.standard.stringArray(forKey: key) {
            favoriteCities = savedCities
        }
    }
    
    private func saveFavorites() {
        UserDefaults.standard.set(favoriteCities, forKey: key)
    }
    
    func addCity(_ city: String) {
        let normalizedCity = city.trimmingCharacters(in: .whitespacesAndNewlines)
        if !normalizedCity.isEmpty && !favoriteCities.contains(normalizedCity) {
            favoriteCities.append(normalizedCity)
            saveFavorites()
        }
    }
    
    func removeCity(at offsets: IndexSet) {
        favoriteCities.remove(atOffsets: offsets)
        saveFavorites()
    }
}
