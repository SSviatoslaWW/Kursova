import SwiftUI

struct DailyForecastItemView: View {
    
    let item: ForecastItem // "Перший" прогноз, який представляє цей день у списку
    let neonGradientColors: [Color]
    
    @ObservedObject var viewModel: WeatherViewModel
    
    @State private var showingDetail = false
    
    var body: some View {
        // Кнопка, що відкриває модальне вікно
        Button(action: {
            showingDetail = true
        }) {
            LazyVStack(alignment: .leading, spacing: 8) {
                
                //ЗАГОЛОВОК
                Text("\(item.dayOfWeekShort) \(item.shortDateString)")
                    .font(.headline)
                    .shadow(color: .white.opacity(0.5), radius: 5)
                    .bold()
                
                // ГОЛОВНИЙ HSTACK
                HStack(spacing: 12) {
                    // --- "іконка" ---
                    SmartWeatherIcon(iconCode: item.weather.first?.icon, size: 70)
                        .id(item.weather.first?.icon)
                        .background(.white.opacity(0.5))
                        .clipShape(Circle())
                        .frame(width: 70)
                    
                    // --- "велика температура" ---
                    Text(item.main.temperatureString)
                        .font(.system(size: 40, weight: .bold))
                        .shadow(color: .white.opacity(0.5), radius: 5)
                        .frame(width: 110, alignment: .center)
                    Spacer()
                    
                    // ---  Деталі ---
                    VStack(alignment: .leading, spacing: 4) {
                        
                        //АДАПТИВНИЙ БЛОК ДЛЯ ВІТРУ ТА ТИСКУ
                        ViewThatFits {
                            
                            // --- Горизонтальний ---
                            HStack(spacing: 12) {
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
                                
                                HStack(spacing: 5) {
                                    Image(systemName: "barometer")
                                        .font(.callout)
                                    Text("\(item.main.pressure) гПа")
                                        .font(.footnote.weight(.medium))
                                }
                                .foregroundColor(.white.opacity(0.9))
                            }
                            
                            // --- Вертикальний ---
                            VStack(alignment: .leading, spacing: 4) {
                                
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
                                
                                HStack(spacing: 5) {
                                    Image(systemName: "barometer")
                                        .font(.callout)
                                    Text("\(item.main.pressure) гПа")
                                        .font(.footnote.weight(.medium))
                                }
                                .foregroundColor(.white.opacity(0.9))
                            }
                            
                        }
                        
                        //"СМУГА З ВОЛОГІСТЮ"
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
            
        }
        
        // --- МОДАЛЬНЕ ВІКНО ---
        .sheet(isPresented: $showingDetail) {
            
            // 1. Отримання ключа дати 
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
