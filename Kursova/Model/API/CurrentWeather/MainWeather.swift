import Foundation

// Структура для основних параметрів (Main)
struct MainWeather: Decodable {
    let temp: Double    // Поточна температура (°C)
    let tempMin: Double // Мінімальна температура
    let tempMax: Double // Максимальна температура
    let humidity: Int   // Вологість (%)
    let pressure: Int   // Тиск (гПа)
    
    // Кодування для відповідності snake_case у JSON
    enum CodingKeys: String, CodingKey {
        case temp, humidity, pressure
        case tempMin = "temp_min"
        case tempMax = "temp_max"
    }
    
    // Обчислювана властивість: Температура, округлена до цілого, з °C
    var temperatureString: String {
        return String(format: "%.0f°C", temp)
    }
}
