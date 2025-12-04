import SwiftUI

struct DailyForecastItemView: View {
    
    let item: ForecastItem // "Перший" прогноз, який представляє цей день у списку
    let neonGradientColors: [Color]
    // 'viewModel' використовується ТІЛЬКИ для модального вікна (.sheet)
    @ObservedObject var viewModel: WeatherViewModel
    
    @State private var showingDetail = false
    
    var body: some View {
        // Кнопка, що відкриває модальне вікно
        Button(action: {
            showingDetail = true
        }) {
            // Головний VStack, що містить Заголовок + Вміст
            LazyVStack(alignment: .leading, spacing: 8) {
                
                // 1. ЗАГОЛОВОК: "Нд 2 лист."
                Text("\(item.dayOfWeekShort) \(item.shortDateString)")
                    .font(.headline)
                    .shadow(color: .white.opacity(0.5), radius: 5) // Неоновий ефект
                    .bold()
                
                // 2. ГОЛОВНИЙ HSTACK: (Іконка 1 | Велика Temp | Деталі)
                HStack(spacing: 12) {
                    // --- КОЛОНКА 1: "іконка" ---
                    SmartWeatherIcon(iconCode: item.weather.first?.icon, size: 70)
                        .id(item.weather.first?.icon)
                        .background(.white.opacity(0.5))
                        .clipShape(Circle())
                        .frame(width: 70) // Фіксуємо ширину колонки
                    
                    // --- КОЛОНКА 2: "велика температура" ---
                    Text(item.main.temperatureString)
                        .font(.system(size: 40, weight: .bold))
                        .shadow(color: .white.opacity(0.5), radius: 5)
                        .frame(width: 110, alignment: .center)
                    Spacer()
                    
                    // --- КОЛОНКА 3: Деталі ---
                    VStack(alignment: .leading, spacing: 4) {
                        
                        // 1. АДАПТИВНИЙ БЛОК ДЛЯ ВІТРУ ТА ТИСКУ
                        // ViewThatFits спробує спочатку Варіант 1 (HStack).
                        // Якщо він не поміститься, він використає Варіант 2 (VStack).
                        ViewThatFits {
                            
                            // --- ВАРІАНТ 1: Горизонтальний ---
                            HStack(spacing: 12) {
                                // Рядок "швидкість вітру"
                                HStack(spacing: 5) {
                                    if let windData = item.wind {
                                        HStack(spacing: 4) {
                                            Image(systemName: "wind")
                                                .font(.callout)
                                            Text(windData.speedString)
                                                .font(.footnote.weight(.medium))
                                        }
                                    }
                                }
                                .foregroundColor(.white.opacity(0.9))
                                
                                Spacer()
                                // Рядок: тиск
                                HStack(spacing: 5) {
                                    Image(systemName: "barometer")
                                        .font(.callout)
                                    Text("\(item.main.pressure) гПа")
                                        .font(.footnote.weight(.medium))
                                }
                                .foregroundColor(.white.opacity(0.9))
                            }
                            
                            // --- ВАРІАНТ 2: Вертикальний ---
                            VStack(alignment: .leading, spacing: 4) {
                                
                                // Рядок: "швидкість вітру"
                                HStack(spacing: 5) {
                                    if let windData = item.wind {
                                        HStack(spacing: 4) {
                                            Image(systemName: "wind")
                                                .font(.callout)
                                            Text(windData.speedString)
                                                .font(.footnote.weight(.medium))
                                        }
                                    }
                                }
                                .foregroundColor(.white.opacity(0.9))
                                
                                // Рядок: тиск
                                HStack(spacing: 5) {
                                    Image(systemName: "barometer")
                                        .font(.callout)
                                    Text("\(item.main.pressure) гПа")
                                        .font(.footnote.weight(.medium))
                                }
                                .foregroundColor(.white.opacity(0.9))
                            }
                            
                        }
                        
                        // 2. "СМУГА З ВОЛОГІСТЮ"
                        HumidityProgressBar(humidity: item.main.humidity, fillColor: AppColors.indicatorCyan)
                            .padding(.top, 4)
                        
                    }
                    
                }
                
            } 
            .foregroundColor(.white)
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .cornerRadius(20)
            .overlay(
                NeonBorder(
                    shape: RoundedRectangle(cornerRadius: 20),
                    colors: neonGradientColors,
                    lineWidth: 3,
                    blurRadius: 4
                )
            )
            
        } // Закриття Button
        
        // --- МОДАЛЬНЕ ВІКНО ---
        .sheet(isPresented: $showingDetail) {
            
            // 1. Отримання ключа дати (початок дня)
            let dateKey = Calendar.current.startOfDay(for: item.date)
            
            // 2. Отримання згрупованих даних для вибраного дня
            let itemsForDay = viewModel.groupedDailyForecast[dateKey] ?? []
            
            // 3. Ініціалізація детальної View
            DailyDetailView(
                dayForecast: itemsForDay,
                dayName: item.fullDayName
            )
        }
    }
}
