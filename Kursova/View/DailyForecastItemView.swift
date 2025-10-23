// Картки 5 денного прогнозу кнопки

import SwiftUI

struct DailyForecastItemView: View {
    
    let item: ForecastItem //Одиничний об'єкт прогнозу, що представляє один день.
    
    @ObservedObject var viewModel: WeatherViewModel // Доступ до загального стану для отримання детального прогнозу на день
    
    @State private var showingDetail = false //Стан, що контролює видимість модального вікна (sheet).
    
    var body: some View {
        // ОБГОРТАЄМО УСЕ В КНОПКУ
        Button(action: {
            showingDetail = true
        }) {
            HStack {
                
                VStack(alignment: .leading, spacing: 2) {
                    //День тижня (скорочена назва)
                    Text(item.dayOfWeekShort)
                        .font(.title3).bold()
                    
                    Text(item.shortDateString) 
                        .font(.body)
                        .foregroundColor(.white.opacity(0.8))
                }
                .frame(width: 90, alignment: .leading)
                
                Spacer()
                
                //Іконка (завантажується з API)
                if let url = item.weather.first?.iconURL {
                    AsyncImage(url: url) { phase in
                        if let image = phase.image {
                            image.resizable().frame(width: 50, height: 50)
                        } else {
                            ProgressView().frame(width: 50, height: 50).tint(.white)
                        }
                    }
                }
                
                Spacer()
                
                // 3. Температура
                Text(item.main.temperatureString)
                    .font(.title2)
                    .bold()
                    .frame(width: 60, alignment: .trailing)
            }
            .foregroundColor(.white)
            // Це гарантує, що вся область, включаючи фон, реагує на натискання.
            //.frame(maxWidth: .infinity) // ⬅️ Розтягує вміст на всю ширину.
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
            .background(Color.white.opacity(0.15)) // Напівпрозорий фон картки.
            .cornerRadius(15)
            
            
        } // Закриття Button
        
        
        //Модальне Вікно (Детальний Прогноз)
        .sheet(isPresented: $showingDetail) {
            
            // 1. Отримання ключа дати (початок дня)
            let dateKey = Calendar.current.startOfDay(for: item.date)
            
            // 2. Отримання згрупованих даних для вибраного дня
            let itemsForDay = viewModel.groupedDailyForecast[dateKey] ?? []
            
            // 3. Ініціалізація детальної View
            DailyDetailView(
                dayForecast: itemsForDay,
                dayName: item.fullDayName // Повна назва дня для заголовка.
            )
        }
    }
}
