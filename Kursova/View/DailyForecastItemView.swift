// DailyForecastItemView.swift

import SwiftUI

struct DailyForecastItemView: View {
    
    // MARK: - Властивості та Стан
    
    let item: ForecastItem // ➡️ Одиничний об'єкт прогнозу, що представляє один день.
    
    @ObservedObject var viewModel: WeatherViewModel // ➡️ Доступ до загального стану (температура, градієнт) та згрупованих даних.
    
    @State private var showingDetail = false // ➡️ Стан, що контролює видимість модального вікна (sheet).
    
    var body: some View {
        // 🛑 ОБГОРТАЄМО УСЕ В КНОПКУ
        Button(action: {
            showingDetail = true // ⬅️ Активуємо модальне вікно при натисканні.
        }) {
            // MARK: - Вміст Картки (HStack)
            HStack {
                
                // 1. День тижня (використовуємо скорочену назву)
                Text(item.dayOfWeekShort) // ⬅️ Виводить скорочену назву (Пн, Вт).
                    .font(.title3).bold()
                    .frame(width: 80, alignment: .leading)
                
                Spacer() // ➡️ Розділяє день та іконку.
                
                // 2. Іконка (завантажується з API)
                if let url = item.weather.first?.iconURL {
                    AsyncImage(url: url) { phase in
                        if let image = phase.image {
                            image.resizable().frame(width: 50, height: 50)
                        } else {
                            ProgressView().frame(width: 50, height: 50).tint(.white) // Заглушка при завантаженні
                        }
                    }
                }
                
                Spacer() // ➡️ Розділяє іконку та температуру.
                
                // 3. Температура
                Text(item.main.temperatureString)
                    .font(.title2)
                    .bold()
                    .frame(width: 60, alignment: .trailing)
            }
            
            // 🛑 Встановлюємо колір вмісту білим для контрасту
            .foregroundColor(.white)
            
            // 🛑 КЛЮЧОВЕ ВИПРАВЛЕННЯ КЛІКАБЕЛЬНОСТІ: Стилі всередині Button
            // Це гарантує, що вся область, включаючи фон, реагує на натискання.
            .frame(maxWidth: .infinity) // ⬅️ Розтягує вміст на всю ширину.
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
            .background(Color.white.opacity(0.15)) // Напівпрозорий фон картки.
            .cornerRadius(15)
            
            
        } // Закриття Button
        
        
        // MARK: - Модальне Вікно (Детальний Прогноз)
        
        .sheet(isPresented: $showingDetail) {
            
            // 1. Отримання ключа дати (початок дня)
            let dateKey = Calendar.current.startOfDay(for: item.date)
            
            // 2. Отримання згрупованих даних для вибраного дня (усі 3-годинні записи)
            let itemsForDay = viewModel.groupedDailyForecast[dateKey] ?? []
            
            // 3. Ініціалізація детальної View
            DailyDetailView(
                dayForecast: itemsForDay,
                dayName: item.fullDayName // Повна назва дня для заголовка.
            )
        }
    }
}
