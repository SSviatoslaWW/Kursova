import Foundation
import Combine

/// Manages the list of favorite cities and their persistence.
class FavoritesViewModel: ObservableObject {
    
    //масив назв міст
    @Published var favoriteCities: [String] = [] {
        didSet {
            //оновлення стану видимості кнопки
            shouldShowEditButton = !favoriteCities.isEmpty
            // збереження змін
            saveFavorites()
        }
    }
    
    //Відповідає за видимість кнопки змінити
    @Published private(set) var shouldShowEditButton: Bool = false
    
    /// The key used to store the list in UserDefaults.
    private let key = "FavoriteCitiesList"
    
    // MARK: - Initialization
    
    init() {
        loadFavorites()
    }
    
    // MARK: - Public Methods
    
    //додавання міста в список
    func addCity(_ city: String) {
        //очищення назви від зайвих пробіліів
        let normalizedCity = city.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !normalizedCity.isEmpty && !favoriteCities.contains(normalizedCity) {
            favoriteCities.append(normalizedCity) // This will trigger `didSet`.
        }
    }
    
    //Видалення міста зі списку
    func removeCity(at offsets: IndexSet) {
        favoriteCities.remove(atOffsets: offsets) // This will trigger `didSet`.
    }
    
    /// Завантаження списку зі сховища
    private func loadFavorites() {
        if let savedCities = UserDefaults.standard.stringArray(forKey: key) {
            favoriteCities = savedCities // викличе didset при першому завантажені
        }
    }
    
    /// Saves the current list of favorite cities to UserDefaults.
    /// This is now called automatically from the `didSet` of `favoriteCities`.
    private func saveFavorites() {
        UserDefaults.standard.set(favoriteCities, forKey: key)
    }
}
