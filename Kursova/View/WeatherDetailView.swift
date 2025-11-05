import SwiftUI

// MARK: - Допоміжне розширення для закриття клавіатури
extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

/// Створює ЯСКРАВУ неонову рамку з кольорами, що "біжать" по колу.
struct AnimatedNeonBorder<S: Shape>: View {
    let shape: S
    let colors: [Color]
    let lineWidth: CGFloat
    let blurRadius: CGFloat
    
    // 1. Стан для відстеження кута градієнта
    @State private var gradientStartAngle: Double = 0
    
    var body: some View {
        
        // 2. Створюємо градієнт, чиї кути будуть анімовані
        let gradient = AngularGradient(
            gradient: Gradient(colors: colors),
            center: .center,
            // 👇 Ми анімуємо ці значення
            startAngle: .degrees(gradientStartAngle),
            endAngle: .degrees(gradientStartAngle + 360)
        )
        
        ZStack {
            // Шар 1: Широке "сяйво" (haze)
            shape
                .stroke(gradient, lineWidth: lineWidth)
                .blur(radius: blurRadius)
            
            // Шар 2: Яскрава "серцевина" (hot core)
            shape
                .stroke(gradient, lineWidth: lineWidth / 2)
                .blur(radius: blurRadius / 3)
        }
        
        
        // 4. Запускаємо анімацію для нашого стану
        .onAppear {
            withAnimation(
                .linear(duration: 4) // 4 секунди на повний оберт
                    .repeatForever(autoreverses: false)
            ) {
                // Ми анімуємо саме змінну стану, а не View
                gradientStartAngle = 360
            }
        }
    }
}




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
                Image(viewModel.getBackground())
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .overlay(
                        // Додаємо накладення чорного кольору
                        Color.black
                        // Встановлюємо прозорість (0.0 = повністю прозорий, 1.0 = повністю чорний)
                        // Можете погратися з цим значенням, щоб досягти бажаного ефекту
                            .opacity(0.5)
                            .ignoresSafeArea() // Переконайтеся, що накладення теж ігнорує безпечні зони
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
    
    // MARK: - Внутрішні компоненти UI (Subviews)
    
    
    
    /// Панель пошуку з неоновим стилем та автозаповненням (Overlay версія)
    private struct SearchPanel: View {
        @ObservedObject var viewModel: WeatherViewModel
        @Binding var cityInput: String
        @ObservedObject var searchManager: CitySearchManager
        @FocusState private var isFocused: Bool
        
        let barGradientColors: [Color] = [.cyan, Color(red: 1.0, green: 0, blue: 1.0), .cyan]
        let buttonGradientColors: [Color] = [Color(red: 1.0, green: 0, blue: 1.0), .pink, Color(red: 1.0, green: 0, blue: 1.0)]
        
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
                
                // 🛑 ВИПРАВЛЕННЯ: СПИСОК ЯК OVERLAY (щоб не штовхав контент)
                // Ми використовуємо overlay на порожньому Color.clear під полем пошуку,
                // щоб список "випадав" вниз, не займаючи фізичного місця у VStack.
            }
            .overlay(alignment: .top) { // ⬅️ Overlay вирівняний по верху
                
                if isFocused && !searchManager.results.isEmpty && !cityInput.isEmpty {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 0) {
                            ForEach(searchManager.results) { result in
                                Button {
                                    performSearch(for: result.title)
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
                    // Додатковий напівпрозорий темний шар для кращої читабельності на яскравому фоні
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
                    // 🛑 ЗСУВ ВНИЗ: Зміщуємо список під поле пошуку (підберіть значення, ~60-70pt)
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
    
    private struct StatusAndErrorView: View {
        @ObservedObject var viewModel: WeatherViewModel
        
        var body: some View {
            if viewModel.isLoading {
                ProgressView("Оновлення даних...")
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .padding(.vertical, 10)
            } else if let errorMsg = viewModel.errorMessage {
                NeonErrorView(errorMessage: errorMsg)
            }
        }
    }
    
    /// Неонове повідомлення про помилку
        private struct NeonErrorView: View {
            let errorMessage: String
            
            // Неонові кольори для помилки (жовто-червоні)
            let errorGradientColors: [Color] = [.yellow, .orange, .red, .orange, .yellow]
            
            var body: some View {
                VStack(spacing: 10) {
                    // Велика іконка попередження
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.yellow)
                        .shadow(color: .orange, radius: 10) // Неонове світіння іконки
                    
                    // Текст помилки
                    Text(errorMessage)
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                }
                .padding(.vertical, 20)
                .padding(.horizontal, 30)
                .background(Color.black.opacity(0.6)) // Темніший фон для кращого контрасту
                .cornerRadius(20)
                // Неонова рамка
                .overlay(
                    AnimatedNeonBorder(
                        shape: RoundedRectangle(cornerRadius: 20),
                        colors: errorGradientColors,
                        lineWidth: 4,
                        blurRadius: 6
                    )
                )
                // Центрування на екрані
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .padding(.horizontal, 40) // Відступи від країв екрана
            }
        }
    
    
    
    
    
    
    
    private struct WeatherScrollView: View {
        @ObservedObject var viewModel: WeatherViewModel
        @ObservedObject var favoritesVM: FavoritesViewModel
        let geometry: GeometryProxy
        
        var body: some View {
            ScrollView(.vertical, showsIndicators: false) {
                
                if let weather = viewModel.currentWeather {
                    VStack(spacing: 30) {
                        MainWeatherInfo(weather: weather, favoritesVM: favoritesVM)
                        HorizontalForecastSection(viewModel: viewModel)
                        DailyForecastSection(viewModel: viewModel)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                    
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
        
        // Кольори для кнопки
        let neonButtonColors: [Color] = [.cyan, Color(red: 1.0, green: 0, blue: 1.0), .cyan]
        let favoriteColor = Color.yellow // Колір для стану "в улюблених"
        
        var body: some View {
            // 1. Перевіряємо, чи є це місто вже в улюблених (для візуального стану)
            let isFavorite = favoritesVM.favoriteLocations.contains(where: { $0.id == weather.id })
            
            // 2. Головний контейнер (HStack)
            HStack(alignment: .center) {
                // Ліва частина (Інформація про погоду)
                VStack(alignment: .leading, spacing: 8) {
                    Text(weather.name)
                        .font(.largeTitle).bold()
                        .shadow(color: Color.white.opacity(0.5), radius: 7, x: 0, y: 0)
                    
                    Text(weather.main.temperatureString)
                        .font(.system(size: 80, weight: .bold))
                        .lineLimit(1) // Запобігаємо переносу рядка
                        .minimumScaleFactor(0.5) // Дозволяємо тексту зменшуватись
                        .shadow(color: Color.white.opacity(0.5), radius: 7, x: 0, y: 0)
                    
                    Text(weather.weather.first?.description.capitalized ?? "")
                        .font(.title3).fontWeight(.medium)
                }
                
                Spacer() // Розштовхує текст і кнопку по боках
                
                // Права частина (Кнопка "Улюблене")
                Button {
                    // 2. Отримуємо код країни (напр., "UA")
                    let countryCode = weather.sys.country
                    
                    // 3. Конвертуємо код у повну назву
                    let countryName = Locale.current.localizedString(forRegionCode: countryCode) ?? countryCode
                    
                    // 4. Створюємо об'єкт FavoriteLocation З УСІМА ДАНИМИ
                    let newFavorite = FavoriteLocation(
                        id: weather.id,           // <-- ВАШЕ ID МІСТА
                        name: weather.name,
                        country: countryName,
                        lat: weather.coord.lat,
                        lon: weather.coord.lon
                    )
                    
                    // 5. Викликаємо нову функцію
                    favoritesVM.addLocation(newFavorite)
                    
                } label: {
                    // ZStack для накладання іконки на бордюр
                    ZStack {
                        // Анімований неоновий бордюр
                        AnimatedNeonBorder(
                            shape: Circle(),
                            // Кнопка змінює колір, якщо вона "активна"
                            colors: isFavorite ? [favoriteColor, .orange, favoriteColor] : neonButtonColors,
                            lineWidth: 3,
                            blurRadius: 5
                        )
                        
                        // Іконка (заповнена або пуста)
                        Image(systemName: isFavorite ? "star.fill" : "star")
                            .font(.system(size: 30, weight: .medium))
                        // Змінюємо колір іконки та додаємо сяйво
                            .foregroundColor(isFavorite ? favoriteColor : .white)
                            .shadow(color: isFavorite ? favoriteColor.opacity(0.8) : .white.opacity(0.5),
                                    radius: isFavorite ? 10 : 5)
                    }
                    .frame(width: 70, height: 70) // Фіксований розмір для кнопки
                }
                .padding(.leading, 10) // Невеликий відступ від тексту
                
            }
            .padding(25) // Внутрішні відступи для всієї картки
            
            // ✅ ЗМІНА ФОНУ: Прибираємо "скло" і додаємо "легку рамку"
            .background(Color.white.opacity(0.01)) // <-- Видалено
            .overlay(
                // Малюємо рамку з тими ж заокругленими кутами
                RoundedRectangle(cornerRadius: 30)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 30)) // Округлені кути (залишаємо)
        }
    }
    
    private struct HorizontalForecastSection: View {
        @ObservedObject var viewModel: WeatherViewModel
        
        var body: some View {
            VStack(alignment: .leading, spacing: 20) {
                Text("Погодинний прогноз")
                    .font(.title2).bold()
                    .padding(.leading)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 40) {
                        // ✅ ВИЗНАЧТЕ ПОВНІ ГРАДІЄНТИ
                        let firstGradientColors: [Color] = [.cyan, Color(red: 0.5, green: 0.8, blue: 1.0), .cyan]
                        let secondGradientColors: [Color] = [Color(red: 1.0, green: 0, blue: 1.0), .pink, Color(red: 1.0, green: 0, blue: 1.0)]
                        
                        // Зберігаємо їх у масиві
                        let allGradients: [[Color]] = [firstGradientColors, secondGradientColors]
                        
                        
                        
                        ForEach(viewModel.forecastItems.indices, id: \.self) { index in
                            let item = viewModel.forecastItems[index]
                            
                            // ✅ Чергуємо градієнти
                            let currentGradient = allGradients[index % allGradients.count]
                            
                            ForecastItemView(item: item, neonGradientColors: currentGradient) // 👈 Передаємо ВЕСЬ градієнт
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical)
                }
                .scrollBounceBehavior(.basedOnSize, axes: .horizontal)
            }
            .padding(.top, 20)
        }
    }
    
    private struct DailyForecastSection: View {
        @ObservedObject var viewModel: WeatherViewModel
        
        var body: some View {
            
            // ✅ ВИЗНАЧТЕ ПОВНІ ГРАДІЄНТИ
            let firstGradientColors: [Color] = [.cyan, Color(red: 0.5, green: 0.8, blue: 1.0), .cyan]
            let secondGradientColors: [Color] = [Color(red: 1.0, green: 0, blue: 1.0), .pink, Color(red: 1.0, green: 0, blue: 1.0)]
            
            // Зберігаємо їх у масиві
            let allGradients: [[Color]] = [firstGradientColors, secondGradientColors]
            
            VStack(alignment: .leading, spacing: 30) {
                Text("Прогноз на 5 днів")
                    .font(.title2).bold()
                
                ForEach(viewModel.dailyForecast.indices, id: \.self) { index in
                    let item = viewModel.dailyForecast[index]
                    // ✅ Чергуємо градієнти
                    let currentGradient = allGradients[index % allGradients.count]
                    
                    DailyForecastItemView(item: item, neonGradientColors: currentGradient, viewModel: viewModel)
                }
            }
            .padding(.top, 20)
        }
    }
}
