// Constants.swift

import Foundation

struct Constants {
    
    // MARK: - API Connection Details
    static let baseURL = "https://api.openweathermap.org/data/2.5/"

    static let apiKey = "52a11ec7b3324b99fad034c62a80c731"
    
    static let units = "metric"
    
    // MARK: - Utility Functions
    
    static func iconURL(iconCode: String) -> URL? {
        // Формуємо повний URL для завантаження іконки
        return URL(string: "https://openweathermap.org/img/wn/\(iconCode)@2x.png")
    }
}
