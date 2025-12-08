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
                    //.frame(width: geometry.size.width, height: geometry.size.height)
                    .ignoresSafeArea(edges: [.top, .bottom, .trailing])
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
                
                if viewModel.isLoading || viewModel.errorMessage != nil {
                    
                    // завантаження або помилка
                    StatusAndErrorView(viewModel: viewModel)
                        .transition(.opacity)
                    
                    Spacer()
                    
                } else {
                    
                    //Показуємо погоду
                    WeatherScrollView(viewModel: viewModel, favoritesVM: favoritesVM, geometry: geometry)
                        .transition(.opacity)
                }
            }
            .foregroundColor(.white)
            // Анімація перемикання між станами
            .animation(.easeInOut, value: viewModel.isLoading)
            .animation(.easeInOut, value: viewModel.errorMessage)
            .frame(height: geometry.size.height)
            .alert("Геолокація недоступна", isPresented: $viewModel.showSettingsAlert) {
                
                // Відкрити налаштування
                Button("Налаштування") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                
                // Скасувати
                Button("Скасувати", role: .cancel) { }
                
            } message: {
                Text("Щоб бачити погоду у вашому регіоні, будь ласка, надайте дозвіл на використання геолокації в налаштуваннях пристрою.")
            }
            
            
        }
        
        .onAppear {
            if viewModel.currentWeather == nil {
                viewModel.requestUserLocation()
            }
        }
        .contentShape(Rectangle()) // Робить всю вільну область клікабельною
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
        
        
    }
}
