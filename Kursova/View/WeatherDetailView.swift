// View/WeatherDetailView.swift

import SwiftUI

// MARK: - 🛑 ДОПОМІЖНЕ РОЗШИРЕННЯ: Функція для примусового закриття клавіатури
extension UIApplication {
    /// Примусово закриває екранну клавіатуру, викликаючи системну дію 'resignFirstResponder'.
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - СТИЛЬ КНОПКИ З ЕФЕКТОМ ГРАДІЄНТА
/// Створює напівпрозору, заокруглену кнопку з анімацією натискання (scale down/fade).
struct GradientPressableButtonStyle: ButtonStyle {
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(
                LinearGradient( // Кастомний градієнтний фон
                    gradient: Gradient(colors: [
                        Color.white.opacity(0.3),
                        Color.white.opacity(configuration.isPressed ? 0.7 : 0.5) // Збільшення прозорості при натисканні
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0) // Ефект стиснення
            .foregroundColor(.white)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}


// MARK: - ГОЛОВНА VIEW: WeatherDetailView

struct WeatherDetailView: View {
    
    // MARK: - Властивості
    
    @ObservedObject var viewModel: WeatherViewModel
    @ObservedObject var favoritesVM: FavoritesViewModel
    @State private var cityInput: String = "" // Стан для тексту в полі пошуку
    
    // MARK: - Body View
    
    var body: some View {
        // 🛑 GeometryReader як кореневий елемент для визначення розмірів екрана
        GeometryReader { geometry in
            ZStack {
                
                // 1. Градієнт ФОНУ
                LinearGradient(
                    gradient: Gradient(colors: viewModel.getBackgroundGradient()),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea(.all) // Заповнюємо весь екран, включаючи Status Bar

                // 2. Основний Контейнер Контенту
                VStack(spacing: 15) {
                    
                    Spacer().frame(height: 1) // Компенсаційний відступ
                    
                    // MARK: - 1. Панель Пошуку
                    SearchPanel(viewModel: viewModel, cityInput: $cityInput)
                    
                    // MARK: - 2. Статус та Помилки
                    StatusAndErrorView(viewModel: viewModel)
                    
                    // MARK: - 3. ОСНОВНИЙ ВЕРТИКАЛЬНИЙ СКРОЛ
                    WeatherScrollView(viewModel: viewModel, favoritesVM: favoritesVM, geometry: geometry)
                }
                .padding(.top, 10)
                .foregroundColor(.white) // Загальний колір тексту
                .shadow(color: .black.opacity(0.8), radius: 5, x: 0, y: 2) // Загальна тінь для контенту
                .background(Color.clear)
            } // Закриття ZStack
        } // Закриття GeometryReader
        
        // MARK: - Системні Модифікатори
        .onAppear {
            // 🛑 АКТИВАЦІЯ CORE LOCATION при першому запуску
            if viewModel.currentWeather == nil {
                viewModel.locationManager.requestLocation()
            }
        }
        // 🛑 ЗАКРИТТЯ КЛАВІАТУРИ ПРИ ТАПІ НА ФОН
        .contentShape(Rectangle())
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
    }
    
    // =============================================================
    // MARK: - ВНУТРІШНІ СТРУКТУРИ UI (Subviews)
    // =============================================================

    /// 1. Структура для Панелі пошуку (TextField та Button)
    private struct SearchPanel: View {
        @ObservedObject var viewModel: WeatherViewModel
        @Binding var cityInput: String
        
        var body: some View {
            HStack {
                TextField("Введіть назву міста", text: $cityInput) // Поле вводу
                    .padding(8)
                    .background(Color.white.opacity(0.3)).cornerRadius(8)
                    .foregroundColor(.white).colorScheme(.dark)
                    .tint(.white) // Колір курсора
                
                Button("Пошук") {
                    if !cityInput.isEmpty {
                        viewModel.fetchWeather(cityInput, nil, nil) // Виклик пошуку за містом
                        UIApplication.shared.endEditing() // Закриття клавіатури
                    }
                }
                .buttonStyle(GradientPressableButtonStyle())
            }
            .padding(.horizontal)
        }
    }
    
    /// 2. Структура для відображення стану завантаження та помилок
    private struct StatusAndErrorView: View {
        @ObservedObject var viewModel: WeatherViewModel
        
        var body: some View {
            if viewModel.isLoading {
                ProgressView("Завантаження погоди...").foregroundColor(.white)
            } else if let errorMsg = viewModel.errorMessage {
                // Вивід помилки (наприклад, "Місто не знайдено")
                Text("❌ \(errorMsg)").foregroundColor(.red).padding()
            }
        }
    }
    
    /// 3. Головний скрол для відображення поточної погоди та прогнозів
    private struct WeatherScrollView: View {
        @ObservedObject var viewModel: WeatherViewModel
        @ObservedObject var favoritesVM: FavoritesViewModel
        let geometry: GeometryProxy // Доступ до розмірів для розрахунку висоти
        
        var body: some View {
            ScrollView(.vertical, showsIndicators: false) {
                
                VStack { // ⬅️ Внутрішній VStack для контенту
                    if let weather = viewModel.currentWeather {
                        VStack(spacing: 10) {
                            
                            // 3.1. Основні дані (Назва, Температура, Кнопка Улюблене)
                            MainWeatherInfo(weather: weather, favoritesVM: favoritesVM, viewModel: viewModel)
                            
                            // 3.2. Горизонтальний Прогноз (24 год)
                            HorizontalForecastSection(viewModel: viewModel)
                            
                            // 3.3. 5-денний Прогноз (Кнопки)
                            DailyForecastSection(viewModel: viewModel)
                            
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                        
                    }
                    
                    // Заглушка, якщо даних немає
                    else if !viewModel.isLoading && viewModel.errorMessage == nil {
                        VStack {
                            Spacer()
                            Text("Введіть місто для перегляду погоди").foregroundColor(.white.opacity(0.8))
                            Spacer()
                        }
                    }
                    
                } // Закриття Внутрішнього VStack
                .frame(minHeight: geometry.size.height - 100) // ⬅️ Розтягування вмісту на весь екран
                .scrollBounceBehavior(.basedOnSize) // Умовне керування відскоком
                
            } // Закриття ScrollView
        }
    }
    
    /// 4. Основна інформаційна картка (Поточна температура)
    private struct MainWeatherInfo: View {
        let weather: CurrentWeatherResponse
        @ObservedObject var favoritesVM: FavoritesViewModel
        @ObservedObject var viewModel: WeatherViewModel
        
        var body: some View {
            VStack(spacing: 10) {
                Text(weather.name).font(.largeTitle).bold()
                
                HStack {
                    if let iconURL = weather.weather.first?.iconURL {
                        AsyncImage(url: iconURL) { phase in
                            if let image = phase.image { image.resizable().frame(width: 100, height: 100) }
                            else { ProgressView().frame(width: 100, height: 100).tint(.white) }
                        }
                    }
                    Text(weather.main.temperatureString).font(.system(size: 80)).fontWeight(.light)
                }
                
                Text(weather.weather.first?.description.capitalized ?? "Невідомо").font(.title3)
                
                Button { favoritesVM.addCity(weather.name) } label: { Label("Додати до Улюблених", systemImage: "star.fill") }
                    .buttonStyle(GradientPressableButtonStyle())
                    .padding(.top)
            }
        }
    }
    
    /// 5. Горизонтальний скрол (Погодинний прогноз)
    private struct HorizontalForecastSection: View {
        @ObservedObject var viewModel: WeatherViewModel
        
        var body: some View {
            VStack(alignment: .leading, spacing: 5) {
                Text("Погодинний Прогноз (24 год)").font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading).padding(.top, 20)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(viewModel.forecastItems, id: \.dt) { item in
                            ForecastItemView(item: item)
                        }
                    }
                }
                .frame(height: 140) // Фіксована висота скролу
                .scrollBounceBehavior(.basedOnSize)
            }
        }
    }
    
    /// 6. Секція 5-денного прогнозу (Кнопки)
    private struct DailyForecastSection: View {
        @ObservedObject var viewModel: WeatherViewModel
        
        var body: some View {
            VStack(alignment: .leading, spacing: 5) {
                Text("Прогноз на 5 днів").font(.title2).bold()
                    .frame(maxWidth: .infinity, alignment: .leading).padding(.top, 20)

                ForEach(viewModel.dailyForecast, id: \.dt) { item in
                    DailyForecastItemView(item: item, viewModel: viewModel) // ⬅️ Кнопки деталізації
                }
            }
        }
    }
}
