import SwiftUI

// Використовуємо 'enum' без кейсів, щоб ніхто не міг створити
// екземпляр цієї структури. Це ідеальне місце для статичних констант.
enum AppColors {
    
    // MARK: - Кастомні кольори
    
    /// Кастомний яскравий 'magenta'
    static let neonMagenta = Color(red: 1.0, green: 0, blue: 1.0)
    
    /// Кастомний 'sky blue'
    static let neonSkyBlue = Color(red: 0.5, green: 0.8, blue: 1.0)
    
    
    // MARK: - Основні кольори UI
    
    /// Жовтий для іконки "Улюблене"
    static let favoriteYellow = Color.yellow
    
    /// Блакитний для індикаторів (напр. вологість)
    static let indicatorCyan = Color.cyan

    
    // MARK: - Неонові Градієнти (Палітри)
    
    /// Градієнт: [.cyan, .magenta, .cyan]
    /// Використання: Панель пошуку, кнопка "Улюблене" (неактивна).
    static let magentaCyan: [Color] = [.cyan, neonMagenta, .cyan]
    
    /// Градієнт: [.magenta, .pink, .magenta]
    /// Використання: Кнопка "Пошук", друга палітра для карток прогнозу.
    static let magentaPink: [Color] = [neonMagenta, .pink, neonMagenta]
    
    /// Градієнт: [.cyan, .blue, .purple, .cyan]
    /// Використання: Кнопка геолокації, рядок у модалці погоди.
    static let oceanCool: [Color] = [.cyan, .blue, .purple, .cyan]
    
    /// Градієнт: [.cyan, .skyBlue, .cyan]
    /// Використання: Перша палітра для карток прогнозу.
    static let skyBlue: [Color] = [.cyan, neonSkyBlue, .cyan]
    
    /// Градієнт: [.cyan, .purple, .cyan]
    /// Використання: Картка улюбленого міста.
    static let cyanPurple: [Color] = [.cyan, .purple, .cyan]
    
    
    // MARK: - Градієнти Станів (Error, Delete, Favorite)

    /// Градієнт для повідомлень про помилки.
    static let error: [Color] = [.yellow, .orange, .red, .orange, .yellow]
    
    /// ГрадієNT для кнопок видалення.
    static let delete: [Color] = [.red, .orange, .red]
    
    /// Градієнт для кнопки "Улюблене" (активна).
    static let favoriteActive: [Color] = [favoriteYellow, .orange, favoriteYellow]
}
