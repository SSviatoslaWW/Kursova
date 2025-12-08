import SwiftUI

struct ContentView: View {
    @StateObject var weatherVM = WeatherViewModel()
    @StateObject var favoritesVM = FavoritesViewModel()
    
    // Стан для програмного керування активною вкладкою
    @State private var selectedTab = 0
    init() {

        let appearance = UITabBarAppearance()
        
        appearance.configureWithOpaqueBackground()
        
        appearance.backgroundColor = UIColor(AppColors.tab)
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        ZStack {
            
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
                    onCitySelect: { selectedCity in
                        // Завантажeння погоди
                        weatherVM.fetchWeather(city: selectedCity.name, lat: selectedCity.lat, lon: selectedCity.lon)
                        //Перемикаємо на вкладку погоди
                        selectedTab = 0
                    },
                    onClose: {
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
#Preview {
    ContentView()
}
