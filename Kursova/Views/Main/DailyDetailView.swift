// діалогове вікно

import SwiftUI

struct DailyDetailView: View {
    @Environment(\.dismiss) var dismiss
    
    let dayForecast: [ForecastItem]
    let dayName: String
    
    private var fullDateString: String {
        guard let firstItem = dayForecast.first else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        formatter.locale = Locale(identifier: "uk_UA")
        return formatter.string(from: firstItem.date)
    }
    
    var body: some View {
        GeometryReader {_ in 
            ZStack {
                
                Image(WeatherViewModel.getBackground(for: dayForecast.first?.weather.first?.main))
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .overlay(
                        Color.black
                            .opacity(0.3)
                            .ignoresSafeArea()
                    )
            }
    
            VStack(spacing: 0) {
                
                // ВЕРХНЯ ПАНЕЛЬ
                CustomHeaderView(dayName: dayName, fullDateString: fullDateString, dismiss: dismiss)
                
                // 2. Скрол для всіх погодинних карток
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(dayForecast, id: \.dt) { item in
                            DetailedForecastRow(item: item)
                        }
                    }
                    .padding()
                }
                .scrollBounceBehavior(.basedOnSize)
            }
            .foregroundColor(.white)
            .shadow(color: .black.opacity(0.4), radius: 3, x: 0, y: 1)
        }
    }
    /// Структура для заголовка та кнопки закриття
    private struct CustomHeaderView: View {
        let dayName: String
        let fullDateString: String
        let dismiss: DismissAction
        
        var body: some View {
            VStack(alignment: .leading, spacing: 5) {
                
                // КНОПКА ЗАКРИТТЯ
                HStack {
                    Spacer()
                    Button("Закрити") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                    .padding(.trailing, 16)
                    .shadow(color: .white, radius: 1)
                    .shadow(color: .white.opacity(0.5), radius: 10)
                }
                .padding(.top, 40)
                
                // ЗАГОЛОВКИ
                Text(dayName)
                    .font(.largeTitle).bold()
                    .shadow(color: .white.opacity(0.5), radius: 10)
                    .padding(.leading, 20)
                
                Text("\(fullDateString)")
                    .font(.headline)
                    .shadow(color: .white.opacity(0.5), radius: 10)
                    .padding(.leading, 20)
            }
            .padding(.bottom, 10)
        }
    }
}
