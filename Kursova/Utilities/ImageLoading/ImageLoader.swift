import SwiftUI
import Combine

// Клас, що відповідає за процес завантаження зображення за URL.
class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    @Published var isLoading = false
    
    private let url: URL?
    private var cancellable: AnyCancellable?

    init(url: URL?) {
        self.url = url
    }
    
    // Скасовуємо запит, якщо об'єкт лоадера знищується (наприклад, в'юха зникає з екрана)
    deinit {
        cancel()
    }

    func load() {
        guard let url = url else { return }
        
        // Якщо зображення вже завантажене, не починаємо знову
        if image != nil { return }
        
        isLoading = true
        
        // 1. ПЕРЕВІРКА КЕШУ: Чи є картинка вже в пам'яті?
        if let cachedImage = ImageCache.shared.object(forKey: url.absoluteString as NSString) {
            // Так, є. Використовуємо її і завершуємо.
            self.image = cachedImage
            self.isLoading = false
            return
        }

        // 2. ЗАВАНТАЖЕННЯ З МЕРЕЖІ: В кеші немає, качаємо.
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) } // Пробуємо створити картинку з даних
            .replaceError(with: nil)        // Ігноруємо помилки
            .receive(on: DispatchQueue.main)// Переходимо на головний потік для оновлення UI
            .sink { [weak self] loadedImage in
                guard let self = self else { return }
                self.isLoading = false
                
                if let loadedImage = loadedImage {
                    // 3. ЗБЕРЕЖЕННЯ В КЕШ: Успішно скачали, зберігаємо на майбутнє.
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
