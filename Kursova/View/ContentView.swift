import SwiftUI

struct ContentView: View {
    @StateObject var weatherVM = WeatherViewModel()
    @StateObject var favoritesVM = FavoritesViewModel()
    
    // Стан для програмного керування активною вкладкою
    @State private var selectedTab = 0
    init() {
        // 1. Створюємо "зовнішній вигляд"
        let appearance = UITabBarAppearance()
        
        // 2. Налаштовуємо його (робимо непрозорим)
        appearance.configureWithOpaqueBackground()
        
        // 3. Встановлюємо колір фону
        appearance.backgroundColor = UIColor(Color.black.opacity(0.4))
        
        // 4. Застосовуємо цей вигляд до обох станів:
        // (standard - коли скрол є, scrollEdge - коли скролу немає)
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        ZStack {
            
            
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
                        // Завантажeння погоди
                        weatherVM.fetchWeather(city: selectedCity.name, lat: nil, lon: nil)
                        //Перемикаємо на вкладку погоди
                        selectedTab = 0
                    },
                    onClose: {
                        selectedTab = 0 // Також просто перемикаємось на першу вкладку
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
#Preview {
    ContentView()
}
