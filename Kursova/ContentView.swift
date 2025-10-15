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
                              // 🛑 ВИПРАВЛЕННЯ: Виклик функції як методу, без зайвих символів
                              weatherVM: weatherVM.withTabSwitch(action: { selectedTab = 0 }))
                    .tabItem {
                        Label("Улюблені", systemImage: "list.star")
                    }
                    .tag(1)
            }
            // 🛑 ВИПРАВЛЕННЯ: Стилі TabView
              .background(Color.clear)
            .tint(.yellow)
            .toolbarBackground(.hidden, for: .tabBar)
        }
    }
} // <--- СТРУКТУРА ЗАКРИТА ТУТ

// MARK: - Допоміжне Розширення для Зручності Перемикання Табів
// 🛑 ВИПРАВЛЕНО: Розширення знаходиться на рівні файлу (зовні struct ContentView)

extension WeatherViewModel {
    
    // Ця функція модифікує оригінальний ViewModel (self)
    func withTabSwitch(action: @escaping () -> Void) -> WeatherViewModel {
        let originalFetchWeather = self.fetchWeather
        
        // Створюємо комбіновану функцію:
        let combinedFetch: (String) -> Void = { city in
            originalFetchWeather(city)
            action() // Викликаємо дію перемикання таба
        }
        
        // Присвоюємо модифіковану функцію
        self.fetchWeather = combinedFetch
        
        // Повертаємо ОРИГІНАЛЬНИЙ ViewModel
        return self
    }
}
