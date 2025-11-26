import Foundation

// Структура для одного запису прогнозу (один 3-годинний інтервал)
struct ForecastItem: Decodable {
    let dt: Int             // Час прогнозу (Unix timestamp)
    let main: MainWeather   // Температурні дані для цього інтервалу
    let weather: [WeatherCondition] // Погодні умови для цього інтервалу
    let wind: Wind?
    
    // Обчислювана властивість: конвертація Unix timestamp у Date
    var date: Date {
        Date(timeIntervalSince1970: TimeInterval(dt))
    }
    
    //Повна назва дня (використовується у модальному вікні)
    var fullDayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE" // Формат: Понеділок
        formatter.locale = Locale(identifier: "uk_UA")
        return formatter.string(from: date).capitalized
    }
    
    //Скорочена назва дня (використовується для карток 5-денного прогнозу)
    var dayOfWeekShort: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE" // Формат: Пн, Вт
        formatter.locale = Locale(identifier: "uk_UA")
        return formatter.string(from: date).capitalized
    }
    
    //Скорочена дата 24 жовт
    var shortDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        formatter.locale = Locale(identifier: "uk_UA")
        return formatter.string(from: date)
    }
}
