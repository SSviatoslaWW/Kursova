import SwiftUI

struct ContentView: View {
    @StateObject var weatherVM = WeatherViewModel()
    @StateObject var favoritesVM = FavoritesViewModel()
    
    // Стан для програмного керування активною вкладкою
    @State private var selectedTab = 0
    
    
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
                        weatherVM.fetchWeather(city: selectedCity, lat: nil, lon: nil)
                        //Перемикаємо на вкладку погоди
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
