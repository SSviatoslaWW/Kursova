// View/FavoritesView.swift

import SwiftUI

struct FavoritesView: View {
    @ObservedObject var favoritesVM: FavoritesViewModel
    @ObservedObject var weatherVM: WeatherViewModel
    
    var body: some View {
        // 🛑 Використовуємо GeometryReader
        GeometryReader { geometry in
            ZStack {
                // 1. Градієнтний Фон (Встановлено у ContentView)
                LinearGradient(
                    gradient: Gradient(colors: weatherVM.getBackgroundGradient()),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea(.all)
                
                VStack {
                    
                    // 🛑 ВІДНОВЛЕННЯ ЗАГОЛОВКА І КНОПКИ РЕДАГУВАННЯ
                    HStack {
                        Text("Улюблені Міста")
                            .font(.largeTitle).bold()
                        
                        Spacer()
                        
                        // 🛑 КНОПКА "Edit"/"Done"
                        EditButton()
                            .foregroundColor(.white)
                    }
                    .padding(.top, 50)
                    .padding(.horizontal)
                    
                    // 🛑 Список
                    List {
                        if favoritesVM.favoriteCities.isEmpty {
                            Text("Натисніть 'Додати до Улюблених' на головному екрані.")
                                .foregroundColor(.secondary)
                                .listRowBackground(Color.white.opacity(0.8))
                        }
                        
                        ForEach(favoritesVM.favoriteCities, id: \.self) { city in
                            Button(action: {
                                weatherVM.fetchWeather(city)
                            }) {
                                HStack {
                                    Text(city).foregroundColor(.primary)
                                    Spacer()
                                    Image(systemName: "cloud.sun").foregroundColor(.gray)
                                }
                            }
                            .listRowBackground(Color.white.opacity(0.8))
                        }
                        // 🛑 ФУНКЦІОНАЛ ВИДАЛЕННЯ: ЗАЛИШАЄМО ТУТ
                        .onDelete(perform: favoritesVM.removeCity)
                        
                    } // Закриття List
                    
                    // 🛑 КЛЮЧОВІ МОДИФІКАТОРИ СПИСКУ
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    
                    // ВИДАЛЯЄМО minHeight ТА ВИКОРИСТОВУЄМО SPACER ЗВЕРХУ
                    // ТА ЗНИЗУ ДЛЯ КРАЩОГО КОНТРОЛЮ
                    
                } // Закриття VStack
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.6), radius: 3, x: 0, y: 1)
            } // Закриття ZStack
        } // Закриття GeometryReader
    }
}
