import SwiftUI

enum AppColors {

    static let neonMagenta = Color(red: 1.0, green: 0, blue: 1.0)
    
    static let neonSkyBlue = Color(red: 0.5, green: 0.8, blue: 1.0)
    
    static let favoriteYellow = Color.yellow
    
    static let indicatorCyan = Color.cyan

    static let magentaCyan: [Color] = [.cyan, neonMagenta, .cyan]
    
    static let magentaPink: [Color] = [neonMagenta, .pink, neonMagenta]
    
    static let oceanCool: [Color] = [.cyan, .blue, .purple, .cyan]
    
    static let skyBlue: [Color] = [.cyan, neonSkyBlue, .cyan]
    
    static let cyanPurple: [Color] = [.cyan, .purple, .cyan]

    static let error: [Color] = [.yellow, .orange, .red, .orange, .yellow]
    
    static let delete: [Color] = [.red, .orange, .red]
    
    static let favoriteActive: [Color] = [favoriteYellow, .orange, favoriteYellow]
    
    static let divider: [Color] = [.cyan, .purple]
    
    static let dropDownListBorder: [Color] = [.cyan, Color(red: 1.0, green: 0, blue: 1.0), .cyan]
    
    static let backroundDropDownList: [Color] = [Color(red: 0.1, green: 0.05, blue: 0.2).opacity(0.95),
                                                 Color.black.opacity(0.98),
                                                 Color(red: 0.05, green: 0.1, blue: 0.2).opacity(0.95)]
    
    static let tab: Color = Color.black.opacity(0.4)
}
