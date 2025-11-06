import SwiftUI

// MARK: - Допоміжне розширення для закриття клавіатури
/*
extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
*/
/// Створює ЯСКРАВУ неонову рамку з кольорами, що "біжать" по колу.
/*struct AnimatedNeonBorder<S: Shape>: View {
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
*/



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
}
