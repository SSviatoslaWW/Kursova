import SwiftUI

// MARK: - Допоміжна Зовнішня Структура
struct WeatherIcon: View {
    let url: URL?
    
    var body: some View {
        //обробляє коректно якщо if поверне nil
        Group {
            if let url = url {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image.resizable().frame(width: 50, height: 50).background(.ultraThinMaterial)
                            .clipShape(Circle())
                    } else {
                        ProgressView().frame(width: 30, height: 30).tint(.white)
                    }
                }
            }
        }
    }
}
