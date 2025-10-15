import Foundation


struct Constants {
    static let baseURL = "https://api.openweathermap.org/data/2.5/"
    static let apiKey = "52a11ec7b3324b99fad034c62a80c731"
    static let units = "metric" // Температура в Цельсіях (°C)
    
    // Функція для формування URL іконки
    static func iconURL(iconCode: String) -> URL? {
        URL(string: "https://openweathermap.org/img/wn/\(iconCode)@2x.png")
    }
}
