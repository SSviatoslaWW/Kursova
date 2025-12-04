import SwiftUI

enum AppColors {
    /// Кастомний яскравий 'magenta'
    static let neonMagenta = Color(red: 1.0, green: 0, blue: 1.0)
    
    /// Кастомний 'sky blue'
    static let neonSkyBlue = Color(red: 0.5, green: 0.8, blue: 1.0)
    
    /// Жовтий для іконки "Улюблене"
    static let favoriteYellow = Color.yellow
    
    /// Блакитний для індикаторів (напр. вологість)
    static let indicatorCyan = Color.cyan

    /// Використання: Панель пошуку, кнопка "Улюблене" (неактивна).
    static let magentaCyan: [Color] = [.cyan, neonMagenta, .cyan]
    
    /// Використання: Кнопка "Пошук", друга палітра для карток прогнозу.
    static let magentaPink: [Color] = [neonMagenta, .pink, neonMagenta]
    
    /// Використання: Кнопка геолокації, рядок у модалці погоди.
    static let oceanCool: [Color] = [.cyan, .blue, .purple, .cyan]
    
    /// Використання: Перша палітра для карток прогнозу.
    static let skyBlue: [Color] = [.cyan, neonSkyBlue, .cyan]
    
    /// Використання: Картка улюбленого міста.
    static let cyanPurple: [Color] = [.cyan, .purple, .cyan]

    /// Градієнт для повідомлень про помилки.
    static let error: [Color] = [.yellow, .orange, .red, .orange, .yellow]
    
    /// ГрадієNT для кнопок видалення.
    static let delete: [Color] = [.red, .orange, .red]
    
    /// Градієнт для кнопки "Улюблене" (активна).
    static let favoriteActive: [Color] = [favoriteYellow, .orange, favoriteYellow]
    
    //колір для divider
    static let divider: [Color] = [.cyan, .purple]
    
    //Шапка випадаючого списку рамка
    static let dropDownListBorder: [Color] = [.cyan, Color(red: 1.0, green: 0, blue: 1.0), .cyan]
    
    //Фон випадаючого списку
    static let backroundDropDownList: [Color] = [Color(red: 0.1, green: 0.05, blue: 0.2).opacity(0.95),
                                                 Color.black.opacity(0.98),
                                                 Color(red: 0.05, green: 0.1, blue: 0.2).opacity(0.95)]
    
    //Колрі tab на старих версіях
    static let tab: Color = Color.black.opacity(0.4)
}
