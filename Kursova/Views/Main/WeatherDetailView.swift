import SwiftUI

struct WeatherDetailView: View {
    
    @ObservedObject var viewModel: WeatherViewModel
    @ObservedObject var favoritesVM: FavoritesViewModel
    @State private var cityInput: String = ""
    
    @StateObject private var searchManager = CitySearchManager()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                // Фон, що заповнює весь екран
                Image(WeatherViewModel.getBackground(for: viewModel.currentWeather?.weather.first?.main))
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .ignoresSafeArea()
                    .overlay(
                        Color.black
                            .opacity(0.5)
                            .ignoresSafeArea()
                    )
                // Основний контент
                VStack(spacing: 20) {
                    
                    // Панель пошуку
                    SearchPanel(viewModel: viewModel, cityInput: $cityInput, searchManager: searchManager)
                        .zIndex(2)
                    
                    // Умова: АБО статус, АБО погода
                    if viewModel.isLoading || viewModel.errorMessage != nil {
                        
                        // ВАРІАНТ А: Йде завантаження або помилка
                        StatusAndErrorView(viewModel: viewModel)
                            .transition(.opacity)
                        
                        // Важливо: Додаємо Spacer, щоб заповнити порожнє місце знизу,
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
                .alert("Геолокація недоступна", isPresented: $viewModel.showSettingsAlert) {
                    
                    // Кнопка 1: Відкрити налаштування
                    Button("Налаштування") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                    
                    // Кнопка 2: Скасувати
                    Button("Скасувати", role: .cancel) { }
                    
                } message: {
                    Text("Щоб бачити погоду у вашому регіоні, будь ласка, надайте дозвіл на використання геолокації в налаштуваннях пристрою.")
                }
                
            }
            
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
