// ContentView.swift

import SwiftUI

struct ContentView: View {
    @StateObject var weatherVM = WeatherViewModel()
    @StateObject var favoritesVM = FavoritesViewModel()
    // Для можливості програмного перемикання Tab
    @State private var selectedTab = 0
    
    var body: some View {
        // 🛑 КРОК 1: ZStack для глобального градієнта (ФОН)
        ZStack {
            
            // 1. Глобальний Градієнт (На задньому плані)
            LinearGradient(
                gradient: Gradient(colors: weatherVM.getBackgroundGradient()),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea(.all)
            
            // 2. TabView: розміщується поверх градієнта
            TabView(selection: $selectedTab) {
                
                // Вкладка "Погода"
                WeatherDetailView(viewModel: weatherVM, favoritesVM: favoritesVM)
                    .tabItem {
                        Label("Погода", systemImage: "cloud.sun.fill")
                    }
                    .tag(0)
                
                // Вкладка "Улюблені"
                FavoritesView(favoritesVM: favoritesVM,
                              // 🛑 ВИПРАВЛЕНО: Виклик функції як методу
                              weatherVM: weatherVM.withTabSwitch(action: { selectedTab = 0 }))
                    .tabItem {
                        Label("Улюблені", systemImage: "list.star")
                    }
                    .tag(1)
            }
            // 🛑 ВИПРАВЛЕННЯ: Стилі TabView
            .background(Color.clear)
            .tint(.orange) // Змінено на жовтий для кращого контрасту
            .toolbarBackground(.hidden, for: .tabBar)
        }
    }
} // <--- СТРУКТУРА ЗАКРИТА ТУТ

// MARK: - Допоміжне Розширення для Зручності Перемикання Табів

extension WeatherViewModel {
    
    // 🛑 Ця функція модифікує оригінальний ViewModel (self)
    func withTabSwitch(action: @escaping () -> Void) -> WeatherViewModel {
        
        // Зберігаємо оригінальну функцію з 3 аргументами
        let originalFetchWeather = self.fetchWeather
        
        // 🛑 Створюємо функцію, яка приймає city, але має тип, сумісний з присвоєнням
        let combinedFetch: (String?, Double?, Double?) -> Void = { city, lat, lon in
            
            // Викликаємо оригінальну функцію з 3 аргументами
            originalFetchWeather(city, lat, lon)
            
            // Перемикаємо вкладку, якщо це був виклик із FavoritesView (city != nil і без координат)
            if lat == nil && lon == nil && city != nil {
                action()
            }
        }
        
        // 🛑 ПРИСВОЄННЯ: Ми присвоюємо нову функцію, яка має коректний тип
        self.fetchWeather = combinedFetch
        
        return self
    }
}
