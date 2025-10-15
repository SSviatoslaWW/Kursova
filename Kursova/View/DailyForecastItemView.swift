
import SwiftUI

struct DailyForecastItemView: View {
    let item: ForecastItem
    
    var body: some View {
        HStack {
            // День тижня
            Text(item.dayOfWeek)
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
        .padding(.vertical, 10)
        .padding(.horizontal, 20)
        .background(Color.white.opacity(0.15)) // Напівпрозорий фон картки
        .cornerRadius(15)
    }
}
