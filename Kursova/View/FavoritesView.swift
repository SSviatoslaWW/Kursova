import SwiftUI

struct FavoritesView: View {
    @ObservedObject var favoritesVM: FavoritesViewModel
    @ObservedObject var weatherVM: WeatherViewModel
    
    // ЗМІНЕНО: Тепер передаємо цілий об'єкт FavoriteLocation
    let onCitySelect: (FavoriteLocation) -> Void
    
    // 👇 ДОДАЙТЕ ЦЕ: Замикання для простого переходу назад/на головну
    let onClose: () -> Void
    
    @State private var isEditing: Bool = false
    
    // MARK: - Body
    
    var body: some View {
        GeometryReader {_ in
            ZStack {
                Image(weatherVM.getBackground())
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
            
            VStack(spacing: 0) {
                HeaderView(
                    isEditing: $isEditing,
                    showEditButton: favoritesVM.shouldShowEditButton,
                    onGeolocationTap: {
                        // 1. Викликаємо примусове оновлення локації
                        weatherVM.forceRefreshUserLocation()
                        // 2. Закриваємо екран улюблених (переходимо на головну вкладку)
                        onClose()
                    }
                )
                
                // ЗМІНЕНО: Перевіряємо .favoriteLocations
                if favoritesVM.favoriteLocations.isEmpty {
                    EmptyStateView()
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            // ЗМІНЕНО: Цикл по .favoriteLocations
                            ForEach(favoritesVM.favoriteLocations.indices, id: \.self) { index in
                                // Перевірка на випадок асинхронного видалення
                                if index < favoritesVM.favoriteLocations.count {
                                    let location = favoritesVM.favoriteLocations[index]
                                    
                                    CityCardRow(
                                        location: location,
                                        index: index,
                                        isEditing: isEditing,
                                        favoritesVM: favoritesVM,
                                        onSelect: {
                                            onCitySelect(location) // Передаємо весь об'єкт
                                        }
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 10)
                    }
                    .scrollBounceBehavior(.basedOnSize)
                }
            }
            .foregroundColor(.white)
            // ЗМІНЕНО: Відстежуємо .favoriteLocations
            .onChange(of: favoritesVM.favoriteLocations) { oldValue, newValue in
                if newValue.isEmpty && isEditing {
                    withAnimation(.spring()) {
                        isEditing = false
                    }
                }
            }
        }
    }
    
    // MARK: - Subviews (Header, EmptyState)
    
    private struct EmptyStateView: View {
        var body: some View {
            Text("Міста, які ви додасте до улюблених, з'являться тут.")
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundColor(.white.opacity(0.8))
                .padding(.top, 50)
                .padding(.horizontal)
        }
    }
    
    private struct HeaderView: View {
        @Binding var isEditing: Bool
        let showEditButton: Bool
        var onGeolocationTap: () -> Void // Дія при натисканні на кнопку геолокації
        
        var body: some View {
            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    Text("Улюблені")
                        .font(.largeTitle).bold()
                        .shadow(color: .white.opacity(0.5), radius: 3, x: 0, y: 0)
                    Spacer()
                    
                    if showEditButton {
                        Button(isEditing ? "Готово" : "Змінити") {
                            withAnimation(.spring()) {
                                isEditing.toggle()
                            }
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .shadow(color: .white.opacity(0.5), radius: 3, x: 0, y: 0)
                        .transition(.opacity.combined(with: .scale))
                    }
                }
                
                HStack(alignment: .center) {
                    Spacer()
                    // Кнопка "Моя Геолокація"
                    Button(action: onGeolocationTap) {
                        HStack(spacing: 10) {
                            Image(systemName: "location.fill")
                                .font(.body)
                                .shadow(color: .white.opacity(0.5), radius: 3, x: 0, y: 0)
                            Text("Моя Геолокація")
                                .font(.body).bold()
                                .shadow(color: .white.opacity(0.5), radius: 3, x: 0, y: 0)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            ZStack {
                                // Неонова рамка (переконайся, що AnimatedNeonBorder доступна)
                                AnimatedNeonBorder(
                                    shape: RoundedRectangle(cornerRadius: 25.0),
                                    colors: [.cyan, .blue, .purple, .cyan],
                                    lineWidth: 3,
                                    blurRadius: 6
                                )
                            }
                        )
                        .cornerRadius(25.0)
                        .shadow(color: .black.opacity(0.4), radius: 8, x: 0, y: 4)
                    }
                    .padding(.top, 5)
                    Spacer()
                }
            }
            .padding(.top, 50)
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
            // Анімація застосовується до появи кнопки "Змінити"
            .animation(.spring(), value: showEditButton)
        }
    }
    
    // --- ОСНОВНА ЗМІНА У CityCardRow ---
    private struct CityCardRow: View {
        let location: FavoriteLocation // Тепер це об'єкт
        let index: Int
        let isEditing: Bool
        @ObservedObject var favoritesVM: FavoritesViewModel
        let onSelect: () -> Void
        
        // Кольори для кнопки видалення
        let deleteButtonColors: [Color] = [.red, .orange, .red]
        
        // ✅ НОВІ КОЛЬОРИ: Для рамки самої картки
        let cardNeonColors: [Color] = [.cyan, .purple, .cyan]
        
        var body: some View {
            HStack(spacing: 15) {
                if isEditing {
                    // --- Кнопка Видалення (без змін) ---
                    Button(action: {
                        withAnimation(.spring()) {
                            favoritesVM.removeLocation(at: IndexSet(integer: index))
                        }
                    }) {
                        ZStack {
                            AnimatedNeonBorder(
                                shape: Circle(),
                                colors: deleteButtonColors,
                                lineWidth: 3,
                                blurRadius: 4
                            )
                            .frame(width: 50, height: 50)
                            
                            Image(systemName: "trash.fill")
                                .foregroundColor(.white)
                                .font(.title2)
                                .shadow(color: .red.opacity(0.8), radius: 5, x: 0, y: 0)
                        }
                    }
                    .transition(.move(edge: .leading).combined(with: .opacity))
                }
                
                // --- Головна Кнопка Картки ---
                Button(action: {
                    if !isEditing { onSelect() }
                }) {
                    HStack {
                        
                        // --- 1. ЛІВА КОЛОНКА (Назва і країна) ---
                        VStack(alignment: .leading, spacing: 4) {
                            Text(location.name)
                                .font(.title2)
                                .fontWeight(.bold)
                            // ✅ НЕОНОВИЙ ТЕКСТ: Додаємо біле світіння
                                .shadow(color: .white.opacity(0.7), radius: 7, x: 0, y: 0)
                            
                            Text(location.country)
                                .font(.callout)
                                .foregroundColor(.white.opacity(0.8))
                            // ✅ НЕОНОВИЙ ТЕКСТ: Слабше світіння
                                .shadow(color: .white.opacity(0.5), radius: 3, x: 0, y: 0)
                        }
                        
                        Spacer()
                        
                        // --- 2. ПРАВА КОЛОНКА (Координати з іконками) ---
                        VStack(alignment: .leading, spacing: 8) {
                            // Широта
                            HStack(spacing: 5) {
                                Image(systemName: "arrow.up.and.down.circle")
                                    .font(.caption)
                                Text(String(format: "%.2f°", location.lat))
                                    .font(.callout).bold()
                            }
                            
                            // Довгота
                            HStack(spacing: 5) {
                                Image(systemName: "arrow.left.and.right.circle")
                                    .font(.caption)
                                Text(String(format: "%.2f°", location.lon))
                                    .font(.callout).bold()
                            }
                        }
                        .foregroundColor(.white.opacity(0.9))
                        // ✅ НЕОНОВИЙ ТЕКСТ: Світіння для координат
                        .shadow(color: .white.opacity(0.6), radius: 5, x: 0, y: 0)
                        
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    // .background(Color.white.opacity(0.15)) // ❌ ВИДАЛЕНО
                    
                    // ✅ НЕОНОВА ОБГОРТКА: Додаємо AnimatedNeonBorder замість .background
                    .overlay(
                        AnimatedNeonBorder(
                            shape: RoundedRectangle(cornerRadius: 16),
                            colors: cardNeonColors, // 👈 Нові кольори
                            lineWidth: 5,
                            blurRadius: 5
                        )
                    )
                    // Обрізаємо вміст за тими ж кутами
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
        }
    }
}
