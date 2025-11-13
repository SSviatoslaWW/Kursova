import SwiftUI

// MARK: - Головна View
struct WeatherDetailView: View {
    
    // MARK: - Властивості
    
    @ObservedObject var viewModel: WeatherViewModel
    @ObservedObject var favoritesVM: FavoritesViewModel
    @State private var cityInput: String = ""
    
    @StateObject private var searchManager = CitySearchManager()
    
    // MARK: - Body
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                // Фон, що заповнює весь екран
                Image(WeatherViewModel.getBackground(for: viewModel.currentWeather?.weather.first?.main))
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .overlay(
                        Color.black
                            .opacity(0.5)
                            .ignoresSafeArea()
                    )
            }
            // Основний контент
            VStack(spacing: 20) {
                
                // Панель пошуку
                SearchPanel(viewModel: viewModel, cityInput: $cityInput, searchManager: searchManager)
                    .zIndex(2)
                
                // Індикатор завантаження або повідомлення про помилку
                StatusAndErrorView(viewModel: viewModel)
                
                // Основний скрол з даними про погоду
                WeatherScrollView(viewModel: viewModel, favoritesVM: favoritesVM, geometry: geometry)
            }
            .foregroundColor(.white)
            .frame(height: geometry.size.height)
            
        }
        .onAppear {
            if viewModel.currentWeather == nil {
                viewModel.requestUserLocation()
            }
        }
        .contentShape(Rectangle()) // Робить всю вільну область клікабельною
        .onTapGesture {
            // Закриваємо клавіатуру при тапі на фон
            UIApplication.shared.endEditing()
        }
    }
}
