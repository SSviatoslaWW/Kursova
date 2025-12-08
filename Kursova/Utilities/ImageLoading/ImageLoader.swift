import SwiftUI
import Combine

// Клас, що відповідає за процес завантаження зображення за URL.
class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    @Published var isLoading = false
    
    private let url: URL?
    //зберігає посилання на запит
    private var cancellable: AnyCancellable?

    init(url: URL?) {
        self.url = url
    }
    
    // Скасовуємо запит, якщо об'єкт лоадера знищується
    deinit {
        cancel()
    }

    func load() {
        guard let url = url else { return }
        
        // Якщо зображення вже завантажене, не починаємо знову
        if image != nil { return }
        
        isLoading = true
        
        //Чи є картинка вже в пам'яті?
        if let cachedImage = ImageCache.shared.object(forKey: url.absoluteString as NSString) {
            self.image = cachedImage
            self.isLoading = false
            return
        }

        //беремо з інтернету картинку
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] loadedImage in
                guard let self = self else { return }
                self.isLoading = false
                
                if let loadedImage = loadedImage {
                    //ЗБЕРЕЖЕННЯ В КЕШ
                    ImageCache.shared.setObject(loadedImage, forKey: url.absoluteString as NSString)
                    self.image = loadedImage
                }
            }
    }
    
    // Функція для примусового скасування завантаження
    func cancel() {
        cancellable?.cancel()
    }
}
