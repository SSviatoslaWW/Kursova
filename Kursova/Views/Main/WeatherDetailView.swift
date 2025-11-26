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
                
                // 2. Умова: АБО статус, АБО погода
                if viewModel.isLoading || viewModel.errorMessage != nil {
                    
                    // ВАРІАНТ А: Йде завантаження або помилка
                    StatusAndErrorView(viewModel: viewModel)
                        .transition(.opacity) // Плавна поява
                    
                    // Важливо: Додаємо Spacer, щоб заповнити порожнє місце знизу,
                    // інакше SearchPanel може "з'їхати" вниз по центру екрану.
                    Spacer()
                    
                } else {
                    
                    // ВАРІАНТ Б: Показуємо погоду (тільки коли немає завантаження і помилок)
                    WeatherScrollView(viewModel: viewModel, favoritesVM: favoritesVM, geometry: geometry)
                        .transition(.opacity) // Плавна поява
                }
            }
            .foregroundColor(.white)
            // Анімація перемикання між станами (щоб не було різкого блимання)
            .animation(.easeInOut, value: viewModel.isLoading)
            .animation(.easeInOut, value: viewModel.errorMessage)
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
