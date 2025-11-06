import SwiftUI

struct MainWeatherInfo: View {
    let weather: CurrentWeatherResponse
    @ObservedObject var favoritesVM: FavoritesViewModel
    
    let favoriteColor = AppColors.favoriteYellow
    
    var body: some View {
        let isFavorite = favoritesVM.favoriteLocations.contains(where: { $0.id == weather.id })
        
        HStack(alignment: .center) {
            // Ліва частина (Інформація про погоду)
            VStack(alignment: .leading, spacing: 8) {
                Text(weather.name)
                    .font(.largeTitle).bold()
                    .shadow(color: Color.white.opacity(0.5), radius: 7, x: 0, y: 0)
                
                Text(weather.main.temperatureString)
                    .font(.system(size: 80, weight: .bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .shadow(color: Color.white.opacity(0.5), radius: 7, x: 0, y: 0)
                
                Text(weather.weather.first?.description.capitalized ?? "")
                    .font(.title3).fontWeight(.medium)
            }
            
            Spacer() // Розштовхує текст і кнопку по боках
            
            // Права частина (Кнопка "Улюблене")
            Button {
                let countryCode = weather.sys.country
                let countryName = Locale.current.localizedString(forRegionCode: countryCode) ?? countryCode
                
                let newFavorite = FavoriteLocation(
                    id: weather.id,
                    name: weather.name,
                    country: countryName,
                    lat: weather.coord.lat,
                    lon: weather.coord.lon
                )
                favoritesVM.addLocation(newFavorite)
                
            } label: {
                ZStack {
                    AnimatedNeonBorder(
                        shape: Circle(),
                        colors: isFavorite ? AppColors.favoriteActive : AppColors.magentaCyan,
                        lineWidth: 3,
                        blurRadius: 5
                    )
                    
                    Image(systemName: isFavorite ? "star.fill" : "star")
                        .font(.system(size: 30, weight: .medium))
                        .foregroundColor(isFavorite ? favoriteColor : .white)
                        .shadow(color: isFavorite ? favoriteColor.opacity(0.8) : .white.opacity(0.5),
                                radius: isFavorite ? 10 : 5)
                }
                .frame(width: 70, height: 70)
            }
            .padding(.leading, 10)
            
        }
        .padding(25)
        .background(Color.white.opacity(0.01))
        .overlay(
            RoundedRectangle(cornerRadius: 30)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 30))
    }
}
