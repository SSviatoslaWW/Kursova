// FavoritesViewModel.swift

import Foundation // ⬅️ Необхідний імпорт для роботи з UserDefaults, String та базовими типами.
import Combine   // ⬅️ Необхідний імпорт для використання протоколу ObservableObject.

/// Клас, що керує списком "Улюблених міст" та забезпечує їхнє локальне зберігання.
/// Використовується в архітектурі MVVM.
class FavoritesViewModel: ObservableObject {
    
    // MARK: - Властивості та Конфігурація
    
    /// Масив міст, які відображаються у View.
    /// @Published автоматично сповіщає SwiftUI про будь-які зміни.
    @Published var favoriteCities: [String] = []
    
    /// Ключ, під яким список зберігається в локальній базі даних (UserDefaults).
    private let key = "FavoriteCitiesList"
    
    // MARK: - Ініціалізація
    
    /// Ініціалізатор: Запускається при створенні ViewModel.
    init() {
        loadFavorites() // ⬅️ Одразу завантажуємо збережені міста.
    }
    
    // MARK: - Приватні Методи Зберігання
    
    /// Завантажує список улюблених міст із UserDefaults.
    private func loadFavorites() {
        if let savedCities = UserDefaults.standard.stringArray(forKey: key) {
            favoriteCities = savedCities // Присвоюємо, якщо дані знайдені.
        }
    }
    
    /// Зберігає поточний стан списку favoriteCities у UserDefaults.
    private func saveFavorites() {
        UserDefaults.standard.set(favoriteCities, forKey: key)
    }
    
    // MARK: - Публічні Методи (API для View)
    
    /// Додає нове місто до списку, якщо воно не порожнє і не є дублікатом.
    /// - Parameter city: Назва міста, яку потрібно додати.
    func addCity(_ city: String) {
        // Очищаємо рядок від зайвих пробілів.
        let normalizedCity = city.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Перевірка на порожнечу та дублікати.
        if !normalizedCity.isEmpty && !favoriteCities.contains(normalizedCity) {
            favoriteCities.append(normalizedCity)
            saveFavorites() // ⬅️ Зберігаємо зміну локально.
        }
    }
    
    /// Видаляє місто за його індексом (використовується при свайпі або натисканні кнопки Delete).
    /// - Parameter offsets: Набір індексів, які потрібно видалити.
    func removeCity(at offsets: IndexSet) {
        favoriteCities.remove(atOffsets: offsets)
        saveFavorites() // ⬅️ Зберігаємо зміну локально.
    }
}
