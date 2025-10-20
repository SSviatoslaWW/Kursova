// DailyDetailView.swift

import SwiftUI

struct DailyDetailView: View {
    @Environment(\.dismiss) var dismiss
    
    let dayForecast: [ForecastItem]
    let dayName: String
    
    // MARK: - Обчислювані Властивості та Логіка
    
    /// Форматує дату першого елемента прогнозу (наприклад, "17 жовтня 2025").
    private var fullDateString: String {
        guard let firstItem = dayForecast.first else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        formatter.locale = Locale(identifier: "uk_UA")
        return formatter.string(from: firstItem.date)
    }

    /// Визначає кольори градієнта на основі температури та критичних погодних умов.
    private func getBackgroundGradient(for item: ForecastItem?) -> [Color] {
        guard let weatherData = item else {
            return [Color(red: 0.1, green: 0.1, blue: 0.2), Color(red: 0.3, green: 0.3, blue: 0.4)]
        }
        
        let mainCondition = weatherData.weather.first?.main ?? "Default"
        let temp = weatherData.main.temp
        
        // 1. КРИТИЧНІ УМОВИ
        switch mainCondition {
        case "Thunderstorm": return [Color(red: 0.3, green: 0.1, blue: 0.4), Color(red: 0.1, green: 0.1, blue: 0.15)]
        case "Snow": return [Color(red: 0.6, green: 0.7, blue: 0.9), Color(red: 0.85, green: 0.9, blue: 0.95)]
        case "Rain", "Drizzle": return [Color(red: 0.3, green: 0.4, blue: 0.6), Color(red: 0.4, green: 0.5, blue: 0.7)]
        default: break
        }

        // 2. ТЕМПЕРАТУРНІ КАТЕГОРІЇ
        if temp >= 30 { return [Color(red: 0.9, green: 0.5, blue: 0.1), Color(red: 1.0, green: 0.8, blue: 0.4)] }
        else if temp >= 15 { return [Color(red: 0.2, green: 0.6, blue: 0.85), Color(red: 0.6, green: 0.8, blue: 1.0)] }
        else if temp >= 5 { return [Color(red: 0.4, green: 0.5, blue: 0.6), Color(red: 0.7, green: 0.75, blue: 0.8)] }
        else { return [Color(red: 0.2, green: 0.2, blue: 0.5), Color(red: 0.4, green: 0.4, blue: 0.7)] }
    }
    
    // MARK: - Body View
    
    var body: some View {
        ZStack {
            
            // 1. Градієнт (ФОН)
            LinearGradient(
                gradient: Gradient(colors: getBackgroundGradient(for: dayForecast.first)),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea(.all)
            
            VStack(spacing: 0) {
                
                // 🛑 1. ВЕРХНЯ ПАНЕЛЬ
                CustomHeaderView(dayName: dayName, fullDateString: fullDateString, dismiss: dismiss)
                
                // 2. Скрол для всіх погодинних карток
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(dayForecast, id: \.dt) { item in
                            DetailedForecastRow(item: item)
                        }
                    }
                    .padding()
                    .padding(.bottom, 30) // Відступ від нижнього краю
                }
                .scrollBounceBehavior(.basedOnSize) // Контроль відскоку
            }
            .foregroundColor(.white)
            .shadow(color: .black.opacity(0.4), radius: 3, x: 0, y: 1)
            
        } // Закриття ZStack
        .presentationDetents([.large]) // Повноекранний режим
        .presentationDragIndicator(.hidden) // Приховуємо індикатор
    }
    
    // =============================================================
    // MARK: - ВНУТРІШНЯ СТРУКТУРА UI (HeaderView)
    // =============================================================

    /// Структура для заголовка та кнопки закриття
    private struct CustomHeaderView: View {
        let dayName: String
        let fullDateString: String
        let dismiss: DismissAction
        
        var body: some View {
            VStack(spacing: 5) {
                
                // КНОПКА ЗАКРИТТЯ (Правий кут)
                HStack {
                    Spacer()
                    Button("Закрити") {
                        dismiss() // ⬅️ Викликаємо дію закриття
                    }
                    .foregroundColor(.white)
                    .padding(.trailing, 16)
                }
                .padding(.top, 40) // ⬅️ Відступ від Status Bar (щоб не зливатися)
                
                // ЗАГОЛОВКИ
                Text(dayName)
                    .font(.largeTitle).bold()
                
                Text("Дата: \(fullDateString)")
                    .font(.headline)
            }
            .padding(.bottom, 20)
        }
    }
}
