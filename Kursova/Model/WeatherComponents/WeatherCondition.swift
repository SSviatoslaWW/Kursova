import Foundation

// Структура для погодних умов
struct WeatherCondition: Decodable {
    let main: String        // Основна група (Clear, Rain, Snow) 
    let description: String // Детальний опис
    let icon: String        // Код іконки
    
    // Обчислювана властивість для формування URL іконки
    var iconURL: URL? {
        Constants.iconURL(iconCode: icon)
    }
}
