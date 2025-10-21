import SwiftUI

struct ContentView: View {
    @StateObject var weatherVM = WeatherViewModel()
    @StateObject var favoritesVM = FavoritesViewModel()
    
    // Стан для програмного керування активною вкладкою
    @State private var selectedTab = 0
    
    init() {
        // Налаштовуємо зовнішній вигляд TabBar, щоб він був прозорим
        // і гармоніював з градієнтним фоном.
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        
        // Встановлюємо колір іконок та тексту для звичайного стану
        appearance.stackedLayoutAppearance.normal.iconColor = .white
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        // Встановлюємо колір іконок та тексту для вибраного стану
        appearance.stackedLayoutAppearance.selected.iconColor = .orange
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.orange]
        
        // Застосовуємо налаштування до стандартного вигляду TabBar
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        ZStack {
            // Глобальний градієнтний фон
            LinearGradient(
                gradient: Gradient(colors: weatherVM.getBackgroundGradient()),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea(.all)
            
            // TabView для навігації
            TabView(selection: $selectedTab) {
                
                // Вкладка "Погода"
                WeatherDetailView(viewModel: weatherVM, favoritesVM: favoritesVM)
                    .tabItem {
                        Label("Погода", systemImage: "cloud.sun.fill")
                    }
                    .tag(0)
                
                // Вкладка "Улюблені"
                FavoritesView(
                    favoritesVM: favoritesVM,
                    weatherVM: weatherVM,
                    // Передаємо замикання, яке буде викликано при виборі міста
                    onCitySelect: { selectedCity in
                        // Дія №1: Завантажуємо погоду
                        weatherVM.fetchWeather(city: selectedCity, lat: nil, lon: nil)
                        // Дія №2: Перемикаємо на вкладку погоди
                        selectedTab = 0
                    }
                )
                .tabItem {
                    Label("Улюблені", systemImage: "list.star")
                }
                .tag(1)
            }
            .tint(.orange)
        }
    }
}
