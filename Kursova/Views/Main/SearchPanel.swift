import SwiftUI

/// Панель пошуку з неоновим стилем та автозаповненням (Overlay версія)
struct SearchPanel: View {
    @ObservedObject var viewModel: WeatherViewModel
    @Binding var cityInput: String
    @ObservedObject var searchManager: CitySearchManager
    @FocusState private var isFocused: Bool
    
    let barGradientColors: [Color] = AppColors.magentaCyan
    let buttonGradientColors: [Color] = AppColors.magentaPink
    
    var body: some View {
        VStack(spacing: 0) { // Зовнішній контейнер для вирівнювання
            
            // --- ОСНОВНА ПАНЕЛЬ ПОШУКУ ---
            HStack(spacing: 15) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.white)
                
                ZStack(alignment: .leading) {
                    if cityInput.isEmpty {
                        Text("Введіть назву міста...")
                            .foregroundColor(.white.opacity(0.6))
                    }
                    TextField("", text: $cityInput)
                        .foregroundColor(.white)
                        .tint(.white)
                        .focused($isFocused)
                        .onChange(of: cityInput) { _, newValue in
                            searchManager.queryFragment = newValue
                        }
                        .submitLabel(.search)
                        .onSubmit { performSearch(for: cityInput) }
                }
                
                Button("Пошук") { performSearch(for: cityInput) }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
                    .foregroundColor(.white)
                    .overlay(
                        NeonBorder(shape: Capsule(),
                                   colors: buttonGradientColors,
                                   lineWidth: 3,
                                   blurRadius: 4)
                    )
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .overlay(
                NeonBorder(shape: Capsule(),
                           colors: barGradientColors,
                           lineWidth: 4,
                           blurRadius: 5)
            )
            .padding(.horizontal)
            
        }
        .overlay(alignment: .top) {
            
            // Група об'єднує логіку, щоб ми могли застосувати стиль до результату вибору
            Group {
                if !searchManager.results.isEmpty {
                    // --- ВАРІАНТ 1: СПИСОК ---
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            ForEach(searchManager.results) { result in
                                Button {
                                    performSearch(
                                        for: result.title,
                                        lat: result.coordinate.latitude,
                                        lon: result.coordinate.longitude
                                    )
                                } label: {
                                    VStack(alignment: .leading) {
                                        Text(result.title)
                                            .foregroundColor(.white).bold()
                                            .shadow(color: .cyan.opacity(0.8), radius: 2)
                                        if !result.subtitle.isEmpty {
                                            Text(result.subtitle).font(.caption).foregroundColor(.gray)
                                        }
                                    }
                                    .padding(.vertical, 12)
                                    .padding(.horizontal)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                Divider()
                                    .background(
                                        LinearGradient(colors: AppColors.divider,
                                                       startPoint: .leading,
                                                       endPoint: .trailing)
                                    )
                                    .shadow(color: .purple.opacity(0.8), radius: 2)
                            }
                        }
                    }
                    .scrollBounceBehavior(.basedOnSize)
                    .scrollDisabled(CGFloat(searchManager.results.count) * 65 < 190)
                    .frame(height: calculateHeight())
                    
                } else if let message = searchManager.statusMessage {
                    // --- ВАРІАНТ 2: ПОВІДОМЛЕННЯ ---
                    VStack(spacing: 10) {
                        Image(systemName: "magnifyingglass.circle")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                            .padding(.bottom, 5)
                        Text(message)
                            .foregroundColor(.white)
                            .font(.subheadline)
                    }
                    // Висота для повідомлення фіксована
                    .frame(height: 100)
                    .frame(maxWidth: .infinity)
                }
            }
            .overlay(
                NeonBorder(
                    shape: RoundedRectangle(cornerRadius: 15),
                    colors: AppColors.dropDownListBorder,
                    lineWidth: 3,
                    blurRadius: 5
                )
            )
            .background(
                LinearGradient(
                    gradient: Gradient(colors: AppColors.backroundDropDownList),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(15)
            .padding(.horizontal, 20)
            .offset(y: 60) 
            .transition(.opacity)
        }
    }
    
    // Додаємо optional lat і lon
    private func performSearch(for city: String, lat: Double? = nil, lon: Double? = nil) {
        if !city.isEmpty {
            cityInput = city
            // Передаємо координати, якщо вони є (а вони будуть завдяки нашому менеджеру)
            viewModel.fetchWeather(city: city, lat: lat, lon: lon)
            
            isFocused = false
            UIApplication.shared.endEditing()
            cityInput = ""
        }
    }
    
    // Розрахунок висоти
    private func calculateHeight() -> CGFloat {
        // Приблизна висота одного рядка (текст + підзаголовок + відступи + розділювач)
        let rowHeight: CGFloat = 65
        
        // Рахуємо загальну висоту: к-сть елементів * висоту рядка
        let contentHeight = CGFloat(searchManager.results.count) * rowHeight
        
        // Повертаємо менше з двох: або реальна висота, або ліміт 190
        return min(contentHeight, 190)
    }
}
