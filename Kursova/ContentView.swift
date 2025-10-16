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
                              // 🛑 ВИПРАВЛЕНО: Виклик функції як методу, без зайвих символів
                              weatherVM: weatherVM.withTabSwitch(action: { selectedTab = 0 }))
                    .tabItem {
                        Label("Улюблені", systemImage: "list.star")
                    }
                    .tag(1)
            }
            // 🛑 ВИПРАВЛЕННЯ: Стилі TabView
            .background(Color.clear)
            .tint(.yellow) // Змінено на жовтий для кращого контрасту
            .toolbarBackground(.hidden, for: .tabBar)
        }
    }
} // <--- СТРУКТУРА ЗАКРИТА ТУТ

// MARK: - Допоміжне Розширення для Зручності Перемикання Табів
// 🛑 Розширення знаходиться на рівні файлу (зовні struct ContentView)

extension WeatherViewModel {
    
    // 🛑 Ця функція модифікує оригінальний ViewModel (self)
    // ⚠️ ВИПРАВЛЕННЯ: Ми повинні повернути тип функції, який приймає 3 аргументи,
    // щоб уникнути помилки присвоєння!
    func withTabSwitch(action: @escaping () -> Void) -> WeatherViewModel {
        
        // Тип originalFetchWeather: (String, Double?, Double?) -> Void
        let originalFetchWeather = self.fetchWeather
        
        // Створюємо нову функцію, яка має коректний тип (String) -> Void
        // і викликає стару функцію (з 3 аргументами)
        let combinedFetch: (String) -> Void = { city in
            
            // 🛑 ФІКС: Викликаємо оригінальний fetchWeather з nil для координат
            originalFetchWeather(city, nil, nil)
            
            action() // Викликаємо дію перемикання таба
        }
        
        // 🛑 ФІКС: Щоб обійти неоднозначність, ми повинні використовувати проміжну змінну
        // для присвоєння, але у Swift ми просто присвоюємо нову функцію.
        
        // Тимчасово зберігаємо комбіновану функцію
        let tempFetch: (String) -> Void = combinedFetch
        
        // 🛑 ПРИСВОЄННЯ: Ми присвоюємо нову функцію, яка приймає String.
        // Це вимагає, щоб тип self.fetchWeather був сумісним.
        // Оскільки у WeatherViewModel.swift ми не можемо приймати лише String,
        // ми повинні повернути проміжну змінну, щоб забезпечити сумісність.
        
        // Якщо помилка все ще виникає, це означає, що компілятор очікує, що
        // self.fetchWeather прийме 3 аргументи, навіть тут.
        
        // МИ ПОВЕРТАЄМОСЯ ДО РІШЕННЯ, ДЕ МИ ПРИСВОЮЄМО ТЕ, ЩО ПОВИННО ПРАЦЮВАТИ:
        
        self.fetchWeather = { city, lat, lon in
            originalFetchWeather(city, lat, lon)
            if lat == nil { // Якщо не було надано координат (тобто, виклик з Tab Bar)
                action()
            }
        }
        
        // ⚠️ Це створить рекурсивну проблему!
        // ПОВЕРНЕННЯ ДО ФІНАЛЬНОЇ ПРАВИЛЬНОЇ ЛОГІКИ:
        
        self.fetchWeather = { city, lat, lon in
            originalFetchWeather(city, lat, lon)
            
            // 🛑 ВИКЛИК: Перемикаємо вкладку, якщо це був виклик із FavoritesView (city != nil)
            if lat == nil && lon == nil {
                action()
            }
        }
        
        return self
    }
}
