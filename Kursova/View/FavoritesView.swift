// View/FavoritesView.swift

import SwiftUI

struct FavoritesView: View {
    @ObservedObject var favoritesVM: FavoritesViewModel
    @ObservedObject var weatherVM: WeatherViewModel
    
    // 🛑 ДОДАНО: Стан для режиму редагування
    @State private var isEditing: Bool = false
    
    // Константа для зміщення вмісту
    private let editingOffset: CGFloat = 20
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 1. Градієнтний Фон
                LinearGradient(
                    gradient: Gradient(colors: weatherVM.getBackgroundGradient()),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea(.all)
                
                VStack {
                    
                    // 1. Заголовок та Edit Button
                    HStack {
                        Text("Улюблені Міста")
                            .font(.largeTitle).bold()
                        Spacer()
                        
                        // КНОПКА РЕДАГУВАННЯ
                        Button(isEditing ? "Done" : "Edit") {
                            withAnimation {
                                isEditing.toggle() // Перемикаємо стан
                            }
                        }
                        .foregroundColor(.white)
                    }
                    .padding(.top, 50)
                    .padding(.horizontal, 16)
                    
                    // 2. Список (ScrollView)
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            
                            // Заглушка
                            if favoritesVM.favoriteCities.isEmpty {
                                Text("Натисніть 'Додати до Улюблених' на головному екрані.")
                                    .foregroundColor(.white.opacity(0.8))
                                    .padding(.top, 40)
                            }
                            
                            // 🛑 ВИКОРИСТОВУЄМО FOREACH
                            ForEach(favoritesVM.favoriteCities.indices, id: \.self) { index in
                                let city = favoritesVM.favoriteCities[index]
                                
                                HStack(spacing: 0) { // ⬅️ Головний HStack для керування позицією
                                    
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
                                        .frame(width: editingOffset, alignment: .leading) // Фіксуємо ширину
                                        .padding(.leading, 52)
                                    }

                                    // 🛑 ОСНОВНИЙ ВМІСТ КАРТКИ
                                    Button(action: {
                                        if !isEditing {
                                            weatherVM.fetchWeather(city, nil, nil)
                                        }
                                    }) {
                                        HStack {
                                            Text(city).foregroundColor(.white)
                                            Spacer()
                                            Image(systemName: "cloud.sun").foregroundColor(.white.opacity(0.8))
                                                .padding(.trailing, 15)
                                        }
                                        .padding(.vertical, 15)
                                        .padding(.horizontal, 16)
                                        
                                        // 🛑 ФОН КАРТКИ ТА СТИЛІ
                                        .background(Color.white.opacity(0.15))
                                        .cornerRadius(10)
                                        .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 1)
                                    }
                                    .buttonStyle(.plain)
                                    
                                    // 🛑 ЕФЕКТ ЗМІЩЕННЯ ВМІСТУ: Зміщуємо всю картку вправо, коли isEditing = true
                                    .offset(x: isEditing ? editingOffset : 0)
                                    
                                } // Закриття HStack
                                .clipped() // Обрізаємо вміст, щоб елементи не виходили за межі
                                
                            } // Закриття ForEach
                            
                            Spacer(minLength: geometry.size.height - 300)
                            
                        } // Закриття LazyVStack
                        .padding(.horizontal, 16)
                        
                    } // Закриття ScrollView
                    
                } // Закриття VStack
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.6), radius: 3, x: 0, y: 1)
            } // Закриття ZStack
        } // Закриття GeometryReader
    }
}
