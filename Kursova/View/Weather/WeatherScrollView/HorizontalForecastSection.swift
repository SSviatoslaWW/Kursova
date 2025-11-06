import SwiftUI

struct HorizontalForecastSection: View {
    @ObservedObject var viewModel: WeatherViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Погодинний прогноз")
                .font(.title2).bold()
                .padding(.leading)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 40) {
                    let allGradients: [[Color]] = [AppColors.skyBlue, AppColors.magentaPink]
                    
                    ForEach(viewModel.forecastItems.indices, id: \.self) { index in
                        let item = viewModel.forecastItems[index]
                        let currentGradient = allGradients[index % allGradients.count]
                        
                        ForecastItemView(item: item, neonGradientColors: currentGradient)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical)
            }
            .scrollBounceBehavior(.basedOnSize, axes: .horizontal)
        }
        .padding(.top, 20)
    }
}
