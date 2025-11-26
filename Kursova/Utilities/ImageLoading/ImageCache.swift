import UIKit

// Клас-синглтон для зберігання завантажених зображень у пам'яті.
class ImageCache {
    // Статичний екземпляр, доступний звідусіль
    static let shared = NSCache<NSString, UIImage>()
}
