import SwiftUI

struct SmartWeatherIcon: View {
    @StateObject private var loader: ImageLoader
    
    let size: CGFloat
    let placeholderColor: Color

    init(iconCode: String?, size: CGFloat = 50, placeholderColor: Color = .white.opacity(0.5)) {
        self.size = size
        self.placeholderColor = placeholderColor
        
        var url: URL? = nil
        if let iconCode = iconCode {
            url = Constants.iconURL(iconCode: iconCode)
        }
        
        // Ініціалізація StateObject з цим URL
        _loader = StateObject(wrappedValue: ImageLoader(url: url))
    }
    
    var body: some View {
        Group {
            if let image = loader.image {
                //Картинка успішно завантажена
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else if loader.isLoading {
                //Процес завантаження
                ProgressView()
                    .tint(placeholderColor)
                    .scaleEffect(size > 50 ? 1.0 : 0.7)
            } else {
                //Помилка або відсутність URL
                Image(systemName: "cloud.sun.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(placeholderColor)
                    .padding(size * 0.1) 
            }
        }
        .frame(width: size, height: size)
        .onAppear { loader.load() }
        .onDisappear { loader.cancel() }
    }
}
