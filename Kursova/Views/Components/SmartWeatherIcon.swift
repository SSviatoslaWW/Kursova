import SwiftUI

struct SmartWeatherIcon: View {
    @StateObject private var loader: ImageLoader
    
    let size: CGFloat
    let placeholderColor: Color

    init(iconCode: String?, size: CGFloat = 50, placeholderColor: Color = .white.opacity(0.5)) {
        self.size = size
        self.placeholderColor = placeholderColor
        
        // Формуємо URL
        var url: URL? = nil
        if let iconCode = iconCode {
            url = Constants.iconURL(iconCode: iconCode)
        }
        
        // Ініціалізуємо StateObject з цим URL
        _loader = StateObject(wrappedValue: ImageLoader(url: url))
    }
    
    var body: some View {
        Group {
            if let image = loader.image {
                // ВАРІАНТ 1: Картинка успішно завантажена (з кешу або мережі)
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else if loader.isLoading {
                // ВАРІАНТ 2: Процес завантаження
                ProgressView()
                    .tint(placeholderColor)
                    // Робимо лоадер трохи меншим, якщо сама іконка мала
                    .scaleEffect(size > 50 ? 1.0 : 0.7)
            } else {
                // ВАРІАНТ 3: Помилка або відсутність URL (Плейсхолдер)
                Image(systemName: "cloud.sun.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(placeholderColor)
                    .padding(size * 0.1) 
            }
        }
        .frame(width: size, height: size)
        // Запускаємо завантаження при появі на екрані
        .onAppear { loader.load() }
        // Скасовуємо завантаження, якщо в'юха зникає
        .onDisappear { loader.cancel() }
    }
}
