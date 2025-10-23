import SwiftUI

// MARK: - Допоміжне розширення для закриття клавіатури
extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Стиль кнопки
struct GradientPressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .shadow(color: Color.black.opacity(0.3), radius: 1, x: 0, y: 1)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.white.opacity(0.35),
                        Color.white.opacity(configuration.isPressed ? 0.6 : 0.4)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .foregroundColor(.white)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}


// MARK: - Головна View
struct WeatherDetailView: View {
    
    // MARK: - Властивості
    
    @ObservedObject var viewModel: WeatherViewModel
    @ObservedObject var favoritesVM: FavoritesViewModel
    @State private var cityInput: String = ""
    
    // MARK: - Body
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Фон, що заповнює весь екран
                LinearGradient(
                    gradient: Gradient(colors: viewModel.getBackgroundGradient()),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Основний контент
                VStack(spacing: 15) {
                    
                    // Панель пошуку
                    SearchPanel(viewModel: viewModel, cityInput: $cityInput)
                    
                    // Індикатор завантаження або повідомлення про помилку
                    StatusAndErrorView(viewModel: viewModel)
                    
                    // Основний скрол з даними про погоду
                    WeatherScrollView(viewModel: viewModel, favoritesVM: favoritesVM, geometry: geometry)
                }
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.4), radius: 4, y: 2)
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
    
    // MARK: - Внутрішні компоненти UI (Subviews)
    
    private struct SearchPanel: View {
        @ObservedObject var viewModel: WeatherViewModel
        @Binding var cityInput: String
        
        var body: some View {
            HStack {
                TextField("", text: $cityInput,
                          prompt: Text("Введіть назву міста...")
                    .foregroundColor(.white))
                .padding(10)
                .background(Color.white.opacity(0.35))
                .cornerRadius(10)
                .foregroundColor(.white)
                .tint(.white)
                
                Button("Пошук") {
                    if !cityInput.isEmpty {
                        viewModel.fetchWeather(city: cityInput, lat: nil, lon: nil)
                        UIApplication.shared.endEditing()
                        cityInput = ""
                    }
                }
                .buttonStyle(GradientPressableButtonStyle())
            }
            .padding(.horizontal)
            .padding(.top, 10)
        }
    }
    
    private struct StatusAndErrorView: View {
        @ObservedObject var viewModel: WeatherViewModel
        
        var body: some View {
            if viewModel.isLoading {
                ProgressView("Оновлення даних...")
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .padding(.vertical, 10)
            } else if let errorMsg = viewModel.errorMessage {
                Text("⚠️ \(errorMsg)")
                    .foregroundColor(.yellow)
                    .padding()
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(10)
            }
        }
    }
    
    private struct WeatherScrollView: View {
        @ObservedObject var viewModel: WeatherViewModel
        @ObservedObject var favoritesVM: FavoritesViewModel
        let geometry: GeometryProxy
        
        var body: some View {
            ScrollView(.vertical, showsIndicators: false) {
                
                if let weather = viewModel.currentWeather {
                    VStack(spacing: 20) {
                        MainWeatherInfo(weather: weather, favoritesVM: favoritesVM)
                        HorizontalForecastSection(viewModel: viewModel)
                        DailyForecastSection(viewModel: viewModel)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                    
                } else if !viewModel.isLoading && viewModel.errorMessage == nil {
                    // Заглушка, якщо даних немає
                    Text("Введіть назву міста, щоб побачити погоду.")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                        .frame(height: geometry.size.height / 2)
                }
            }
            .scrollBounceBehavior(.basedOnSize)
        }
    }
    
    private struct MainWeatherInfo: View {
        let weather: CurrentWeatherResponse
        @ObservedObject var favoritesVM: FavoritesViewModel
        
        var body: some View {
            VStack(spacing: 8) {
                Text(weather.name)
                    .font(.largeTitle).bold()
                
                Text(weather.main.temperatureString)
                    .font(.system(size: 80, weight: .thin))
                
                Text(weather.weather.first?.description.capitalized ?? "")
                    .font(.title3).fontWeight(.medium)
                
                Button {
                    favoritesVM.addCity(weather.name)
                } label: {
                    Label("Додати до Улюблених", systemImage: "star")
                }
                .buttonStyle(GradientPressableButtonStyle())
                .padding(.top, 10)
            }
            .padding(.top, 20)
        }
    }
    
    private struct HorizontalForecastSection: View {
        @ObservedObject var viewModel: WeatherViewModel
        
        var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                Text("Погодинний прогноз")
                    .font(.title3).bold()
                    .padding(.leading)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(viewModel.forecastItems, id: \.dt) { item in
                            ForecastItemView(item: item)
                        }
                    }
                    .padding(.horizontal)
                }
                .scrollBounceBehavior(.basedOnSize)
            }
            .padding(.top, 20)
        }
    }
    
    private struct DailyForecastSection: View {
        @ObservedObject var viewModel: WeatherViewModel
        
        var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                Text("Прогноз на 5 днів")
                    .font(.title3).bold()
                    .padding(.leading)
                
                ForEach(viewModel.dailyForecast, id: \.dt) { item in
                    DailyForecastItemView(item: item, viewModel: viewModel)
                }
            }
            .padding(.top, 20)
        }
    }
}
