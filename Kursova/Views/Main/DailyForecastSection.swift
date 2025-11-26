import SwiftUI

struct DailyForecastSection: View {
    @ObservedObject var viewModel: WeatherViewModel
    
    var body: some View {
        
        let allGradients: [[Color]] = [AppColors.skyBlue, AppColors.magentaPink]
        
        VStack(alignment: .leading, spacing: 30) {
            Text("Прогноз на 5 днів")
                .font(.title2).bold()
            
            ForEach(viewModel.dailyForecast.indices, id: \.self) { index in
                let item = viewModel.dailyForecast[index]
                let currentGradient = allGradients[index % allGradients.count]
                
                DailyForecastItemView(item: item, neonGradientColors: currentGradient, viewModel: viewModel)
            }
        }
        .padding(.top, 20)
    }
}
