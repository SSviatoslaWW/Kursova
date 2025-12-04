// Constants.swift

import Foundation

struct Constants {
    
    // MARK: - API Connection Details
    static let baseURL = "https://api.openweathermap.org/data/2.5/"
    //спосіб отримати ключ через посилання у Info.plist
    static var apiKey: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String else {
            fatalError("API_KEY не знайдено в Info.plist.")
        }
        return key
    }
    
    static let units = "metric"
    
    // Формуємо повний URL для завантаження іконки
    static func iconURL(iconCode: String) -> URL? {
        return URL(string: "https://openweathermap.org/img/wn/\(iconCode)@2x.png")
    }
}
