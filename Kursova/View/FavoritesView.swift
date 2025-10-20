// View/FavoritesView.swift

import SwiftUI

// MARK: - FavoritesView (Головна View)

struct FavoritesView: View {
    
    // MARK: - Властивості та Стан
    
    @ObservedObject var favoritesVM: FavoritesViewModel
    @ObservedObject var weatherVM: WeatherViewModel
    
    // 🛑 Стан: Режим редагування
    @State private var isEditing: Bool = false
    
    // Константа для зміщення вмісту в режимі редагування
    private let editingOffset: CGFloat = 20
    private let paddingOffset: CGFloat = 16
    private let itemSpacing: CGFloat = 12
    
    // MARK: - Body View
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 1. Градієнтний Фон (Global)
                LinearGradient(
                    gradient: Gradient(colors: weatherVM.getBackgroundGradient()),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea(.all)
                
                VStack(spacing: 0) {
                    
                    // 1. Заголовок та Кнопка Редагування
                    HeaderView(isEditing: $isEditing)
                    
                    // 2. Список (ScrollView)
                    ScrollView {
                        LazyVStack(spacing: itemSpacing) {
                            
                            // Заглушка, якщо немає міст
                            if favoritesVM.favoriteCities.isEmpty {
                                EmptyStateView()
                            }
                            
                            // 🛑 Картки міст
                            ForEach(favoritesVM.favoriteCities.indices, id: \.self) { index in
                                CityCardRow(
                                    city: favoritesVM.favoriteCities[index],
                                    index: index,
                                    isEditing: isEditing,
                                    editingOffset: editingOffset,
                                    paddingOffset: paddingOffset,
                                    weatherVM: weatherVM,
                                    favoritesVM: favoritesVM
                                )
                            } // Закриття ForEach
                            
                            // Додатковий Spacer для розтягування фону
                            Spacer(minLength: geometry.size.height - 300)
                            
                        } // Закриття LazyVStack
                        .padding(.horizontal, 16)
                        
                    } // Закриття ScrollView
                    .scrollBounceBehavior(.basedOnSize) // Умовне керування відскоком
                    
                } // Закриття VStack (основний)
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.6), radius: 3, x: 0, y: 1)
            } // Закриття ZStack
        } // Закриття GeometryReader
    }
    
    // =============================================================
    // MARK: - ПРИВАТНІ СТРУКТУРИ UI (Subviews)
    // =============================================================
    
    /// Структура для порожнього стану списку.
    private struct EmptyStateView: View {
        var body: some View {
            Text("Натисніть 'Додати до Улюблених' на головному екрані.")
                .foregroundColor(.white.opacity(0.8))
                .padding(.top, 40)
        }
    }
    
    /// Структура для верхнього заголовка та кнопки редагування.
    private struct HeaderView: View {
        @Binding var isEditing: Bool
        
        var body: some View {
            HStack {
                Text("Улюблені Міста")
                    .font(.largeTitle).bold()
                Spacer()
                
                // КНОПКА РЕДАГУВАННЯ
                Button(isEditing ? "Done" : "Edit") {
                    withAnimation {
                        isEditing.toggle()
                    }
                }
                .foregroundColor(.white)
            }
            .padding(.top, 50)
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
        }
    }
    
    /// Структура для окремого елемента міста (Картки)
    private struct CityCardRow: View {
        let city: String
        let index: Int
        let isEditing: Bool
        let editingOffset: CGFloat
        let paddingOffset: CGFloat
        @ObservedObject var weatherVM: WeatherViewModel
        @ObservedObject var favoritesVM: FavoritesViewModel

        var body: some View {
            HStack(spacing: 0) { // Головний HStack для керування позицією
                
                // 🛑 КНОПКА ВИДАЛЕННЯ: ЗАВЖДИ ЗНАХОДИТЬСЯ ЗЛІВА
                if isEditing {
                    Button(action: {
                        withAnimation {
                            favoritesVM.removeCity(at: IndexSet(integer: index))
                        }
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .foregroundColor(.red)
                            .scaleEffect(1.2)
                    }
                    // 🛑 ФІКС ПОЗИЦІЇ: Зміщуємо кнопку вліво на від'ємну величину
                    .frame(width: editingOffset, alignment: .leading)
                    .offset(x: 10) // Негативний зсув для зближення з карткою
                }

                // 🛑 ОСНОВНИЙ ВМІСТ КАРТКИ (Клікабельна область)
                Button(action: {
                    if !isEditing {
                        weatherVM.fetchWeather(city, nil, nil)
                    }
                }) {
                    HStack {
                        Text(city).foregroundColor(.white)
                            .lineLimit(1)
                            .padding(.leading, isEditing ? 8 : 16) // ⬅️ КОМПЕНСАЦІЙНИЙ ВІДСТУП
                        Spacer()
                        Image(systemName: "cloud.sun").foregroundColor(.white.opacity(0.8))
                            .padding(.trailing, 25)
                    }
                    .padding(.vertical, 15)
                    .buttonStyle(.plain)
                    
                    // 🛑 СТИЛІ КАРТКИ
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(10)
                    .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 1)
                }
                
                // 🛑 ЕФЕКТ ЗМІЩЕННЯ ВМІСТУ: Зміщуємо всю картку вправо
                .offset(x: isEditing ? editingOffset : 0)
                
            } // Закриття HStack
            .clipped() // Обрізаємо вміст
        }
    }
}
