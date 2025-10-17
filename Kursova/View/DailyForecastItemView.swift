// DailyForecastItemView.swift

import SwiftUI

struct DailyForecastItemView: View {
    let item: ForecastItem
    @ObservedObject var viewModel: WeatherViewModel
    
    @State private var showingDetail = false
    
    var body: some View {
        // 🛑 ОБГОРТАЄМО УСЕ В КНОПКУ
        Button(action: {
            showingDetail = true // ⬅️ Активуємо модальне вікно при натисканні
        }) {
            HStack {
                // День тижня (використовуємо повну назву)
                Text(item.fullDayName)
                    .font(.title3).bold()
                    .frame(width: 80, alignment: .leading)
                
                Spacer()
                
                // Іконка
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
                
                // Температура
                Text(item.main.temperatureString)
                    .font(.title2)
                    .bold()
                    .frame(width: 60, alignment: .trailing)
            }
            // 🛑 КРОК 1: Розтягуємо HStack на всю доступну ширину
            .frame(maxWidth: .infinity)
            
            // 🛑 КРОК 2: Встановлюємо колір вмісту білим для контрасту
            .foregroundColor(.white)
            
            // 🛑 КРОК 3: Стилі картки
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
            .background(Color.white.opacity(0.15))
            .cornerRadius(15)
            
            // 🛑 КРОК 4: ФІКС КЛІКАБЕЛЬНОСТІ: Змушує кнопку займати всю форму
            .contentShape(Rectangle())
            
        } // Закриття Button
        .buttonStyle(.plain) // Робить усю область клікабельною
        
        // 🛑 ВИДАЛЕНО: Зайві модифікатори, перенесено в Button
        
        // НОВИЙ ЕЛЕМЕНТ: Модальне вікно
        .sheet(isPresented: $showingDetail) {
            
            let dateKey = Calendar.current.startOfDay(for: item.date)
            let itemsForDay = viewModel.groupedDailyForecast[dateKey] ?? []
            
            DailyDetailView(
                dayForecast: itemsForDay,
                dayName: item.fullDayName
            )
        }
    }
}
