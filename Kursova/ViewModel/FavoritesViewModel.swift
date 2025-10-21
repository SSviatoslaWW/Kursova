import Foundation
import Combine

/// Manages the list of favorite cities and their persistence.
class FavoritesViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// The array of city names displayed in the view.
    /// `didSet` is used to automatically update other properties and save data when this array changes.
    @Published var favoriteCities: [String] = [] {
        didSet {
            // Automatically update the button's visibility state.
            shouldShowEditButton = !favoriteCities.isEmpty
            // Save changes to local storage.
            saveFavorites()
        }
    }
    
    /// A pre-calculated boolean that determines if the "Edit" button should be visible.
    /// The View will read this value directly. `private(set)` ensures only this ViewModel can change it.
    @Published private(set) var shouldShowEditButton: Bool = false
    
    // MARK: - Properties
    
    /// The key used to store the list in UserDefaults.
    private let key = "FavoriteCitiesList"
    
    // MARK: - Initialization
    
    init() {
        loadFavorites()
    }
    
    // MARK: - Public Methods
    
    /// Adds a new city to the list if it's not empty and not a duplicate.
    /// - Parameter city: The name of the city to add.
    func addCity(_ city: String) {
        let normalizedCity = city.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !normalizedCity.isEmpty && !favoriteCities.contains(normalizedCity) {
            favoriteCities.append(normalizedCity) // This will trigger `didSet`.
        }
    }
    
    /// Removes cities from the list at specified indices.
    /// - Parameter offsets: A set of indices to remove.
    func removeCity(at offsets: IndexSet) {
        favoriteCities.remove(atOffsets: offsets) // This will trigger `didSet`.
    }

    // MARK: - Private Persistence Methods
    
    /// Loads the list of favorite cities from UserDefaults.
    private func loadFavorites() {
        if let savedCities = UserDefaults.standard.stringArray(forKey: key) {
            favoriteCities = savedCities // This will trigger `didSet` on initial load.
        }
    }
    
    /// Saves the current list of favorite cities to UserDefaults.
    /// This is now called automatically from the `didSet` of `favoriteCities`.
    private func saveFavorites() {
        UserDefaults.standard.set(favoriteCities, forKey: key)
    }
}
