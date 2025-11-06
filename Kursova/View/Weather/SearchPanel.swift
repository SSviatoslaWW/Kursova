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
                        Text("Введіть назву міста...").foregroundColor(.white.opacity(0.6))
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
                        AnimatedNeonBorder(shape: Capsule(), colors: buttonGradientColors, lineWidth: 3, blurRadius: 4)
                    )
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .overlay(
                AnimatedNeonBorder(shape: Capsule(), colors: barGradientColors, lineWidth: 4, blurRadius: 5)
            )
            .padding(.horizontal)
            
        }
        .overlay(alignment: .top) { // ⬅️ Overlay вирівняний по верху
            
            if isFocused && !searchManager.results.isEmpty && !cityInput.isEmpty {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(searchManager.results) { result in
                            Button {
                                let cityName = result.title.components(separatedBy: ",").first?.trimmingCharacters(in: .whitespaces) ?? result.title
                                performSearch(for: cityName)
                                print(cityName)
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
                                    LinearGradient(colors: [.cyan, .purple], startPoint: .leading, endPoint: .trailing)
                                )
                                .shadow(color: .purple.opacity(0.8), radius: 2)
                        }
                    }
                }
                .overlay(
                    AnimatedNeonBorder(
                        shape: RoundedRectangle(cornerRadius: 15), // Форма рамки
                        colors: [.cyan, Color(red: 1.0, green: 0, blue: 1.0), .cyan], // Ваші неонові кольори
                        lineWidth: 3, // Товщина лінії
                        blurRadius: 5 // Радіус світіння
                    )
                )
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.1, green: 0.05, blue: 0.2).opacity(0.95), // Дуже темний фіолетовий
                            Color.black.opacity(0.98),                             // Майже чорний по центру
                            Color(red: 0.05, green: 0.1, blue: 0.2).opacity(0.95)  // Дуже темний синій внизу
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(15)
                .frame(height: 200)
                .padding(.horizontal, 20) // Відступи, щоб відповідати ширині поля
                .offset(y: 60)
                .transition(.opacity)
            }
        }
    }
    
    private func performSearch(for city: String) {
        if !city.isEmpty {
            cityInput = city
            viewModel.fetchWeather(city: city, lat: nil, lon: nil)
            isFocused = false
            UIApplication.shared.endEditing()
            cityInput = ""
        }
    }
}
