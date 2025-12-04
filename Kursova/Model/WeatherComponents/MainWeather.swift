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
    
    // Обчислювана властивість: Температура, округлена до цілого
    var temperatureString: String {
        let roundedTemp = temp.rounded()
        
        // Перевіряємо, чи стало -0.0
        if roundedTemp == 0.0 && roundedTemp.sign == .minus {
            return "0°C" 
        }
        
        // Для всіх інших чисел - повертаємо як було
        return String(format: "%.0f°C", roundedTemp)
    }
}
