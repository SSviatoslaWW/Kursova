// View/DailyDetailView.swift

import SwiftUI

struct DailyDetailView: View {
    @Environment(\.dismiss) var dismiss
    
    let dayForecast: [ForecastItem]
    let dayName: String
    
    // 🛑 НОВЕ: Обчислювана властивість для форматування повної дати
    private var fullDateString: String {
        guard let firstItem = dayForecast.first else { return "" }
        let formatter = DateFormatter()
        // Встановлюємо формат: 17 жовтня 2025
        formatter.dateFormat = "d MMMM yyyy"
        formatter.locale = Locale(identifier: "uk_UA")
        return formatter.string(from: firstItem.date)
    }

    // 🛑 Функція для градієнта (без змін)
    private func getBackgroundGradient(for item: ForecastItem?) -> [Color] {
        guard let weatherData = item else {
            return [Color(red: 0.1, green: 0.1, blue: 0.2), Color(red: 0.3, green: 0.3, blue: 0.4)]
        }
        let mainCondition = weatherData.weather.first?.main ?? "Default"
        let temp = weatherData.main.temp
        
        switch mainCondition {
        case "Thunderstorm": return [Color(red: 0.3, green: 0.1, blue: 0.4), Color(red: 0.1, green: 0.1, blue: 0.15)]
        case "Snow": return [Color(red: 0.6, green: 0.7, blue: 0.9), Color(red: 0.85, green: 0.9, blue: 0.95)]
        case "Rain", "Drizzle": return [Color(red: 0.3, green: 0.4, blue: 0.6), Color(red: 0.4, green: 0.5, blue: 0.7)]
        default: break
        }

        if temp >= 30 { return [Color(red: 0.9, green: 0.5, blue: 0.1), Color(red: 1.0, green: 0.8, blue: 0.4)] }
        else if temp >= 15 { return [Color(red: 0.2, green: 0.6, blue: 0.85), Color(red: 0.6, green: 0.8, blue: 1.0)] }
        else if temp >= 5 { return [Color(red: 0.4, green: 0.5, blue: 0.6), Color(red: 0.7, green: 0.75, blue: 0.8)] }
        else { return [Color(red: 0.2, green: 0.2, blue: 0.5), Color(red: 0.4, green: 0.4, blue: 0.7)] }
    }
    
    var body: some View {
        
        ZStack {
            
            // 1. Градієнт
            LinearGradient(
                gradient: Gradient(colors: getBackgroundGradient(for: dayForecast.first)),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea(.all)
            
            VStack { // ⬅️ Контент
                
                // 🛑 1. КНОПКА ЗАКРИТТЯ
                HStack {
                    Spacer()
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                    .padding(.trailing, 25)
                }
                .padding(.top, 40) // ⬅️ Відступ для Status Bar
                
                // 2. ЗАГОЛОВОК
                Text(dayName) // ⬅️ Назва дня (Субота)
                    .font(.largeTitle).bold()
                
                // 🛑 ВИПРАВЛЕНО: Відображення повної дати
                Text("Дата: \(fullDateString)")
                    .font(.headline)
                    .padding(.bottom, 20)
                
                // 3. Скрол для всіх погодинних карток
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(dayForecast, id: \.dt) { item in
                            DetailedForecastRow(item: item)
                        }
                    }
                    .padding()
                    .padding(.bottom, 30)
                }
            }
            .foregroundColor(.white)
            .shadow(color: .black.opacity(0.4), radius: 3, x: 0, y: 1)
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
    }
}
