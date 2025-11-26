import SwiftUI

struct WeatherScrollView: View {
    @ObservedObject var viewModel: WeatherViewModel
    @ObservedObject var favoritesVM: FavoritesViewModel
    let geometry: GeometryProxy
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            
            if let weather = viewModel.currentWeather {
                VStack(spacing: 30) {
                    MainWeatherInfo(weather: weather,cityName: viewModel.currentCity, favoritesVM: favoritesVM)
                    HorizontalForecastSection(viewModel: viewModel)
                    DailyForecastSection(viewModel: viewModel)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
                
            } else if !viewModel.isLoading && viewModel.errorMessage == nil {
                // Заглушка, якщо даних немає
                Text("Введіть назву міста, щоб побачити погоду.")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.8))
                    .frame(height: geometry.size.height / 2)
            }
        }
        .scrollBounceBehavior(.basedOnSize)
    }
}
