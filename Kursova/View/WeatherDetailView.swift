// View/WeatherDetailView.swift

import SwiftUI

struct WeatherDetailView: View {
    // 🛑 Видалили @Environment(\.safeAreaInsets), щоб уникнути помилок
    
    @ObservedObject var viewModel: WeatherViewModel
    @ObservedObject var favoritesVM: FavoritesViewModel
    @State private var cityInput: String = ""
    
    var body: some View {
        // 🛑 Використовуємо GeometryReader для безпечного визначення висоти
        GeometryReader { geometry in
            ZStack {
                // 1. Градієнт
                LinearGradient(
                    gradient: Gradient(colors: viewModel.getBackgroundGradient()),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea(.all)

                // 2. КОНТЕНТ
                VStack(spacing: 15) {
                    
                    Spacer().frame(height: 1)
                    
                    // MARK: - Пошук Міста
                    HStack {
                        TextField("Введіть назву міста", text: $cityInput)
                            .padding(8)
                            .background(Color.white.opacity(0.3)).cornerRadius(8)
                            .foregroundColor(.white).colorScheme(.dark)
                        
                        Button("Пошук") {
                            viewModel.fetchWeather(cityInput)
                        }
                        .buttonStyle(.borderedProminent).tint(Color.white.opacity(0.5))
                    }
                    .padding(.horizontal)
                    
                    // MARK: - Обробка Стану/Помилки
                    if viewModel.isLoading {
                        ProgressView("Завантаження погоди...").foregroundColor(.white)
                    } else if let errorMsg = viewModel.errorMessage {
                        Text("❌ Помилка: \(errorMsg)").foregroundColor(.red).padding()
                    }
                    
                    // MARK: - ОСНОВНИЙ ВЕРТИКАЛЬНИЙ СКРОЛ
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 15) {
                            
                            // MARK: - Поточна Погода
                            if let weather = viewModel.currentWeather {
                                VStack(spacing: 10) {
                                    Text(weather.name).font(.largeTitle).bold()
                                    
                                    HStack {
                                        if let iconURL = weather.weather.first?.iconURL {
                                            AsyncImage(url: iconURL) { phase in
                                                if let image = phase.image {
                                                    image.resizable().frame(width: 100, height: 100)
                                                } else if phase.error != nil {
                                                    Image(systemName: "xmark.octagon").resizable().frame(width: 100, height: 100)
                                                } else {
                                                    ProgressView().frame(width: 100, height: 100).tint(.white)
                                                }
                                            }
                                        }
                                        Text(weather.main.temperatureString)
                                            .font(.system(size: 80)).fontWeight(.light)
                                    }
                                    
                                    Text(weather.weather.first?.description.capitalized ?? "Невідомо").font(.title3)
                                    
                                    Button { favoritesVM.addCity(weather.name) } label: { Label("Додати до Улюблених", systemImage: "star.fill") }
                                    .buttonStyle(.borderedProminent).tint(.white.opacity(0.5)).padding(.top)
                                    
                                    // MARK: - 1. Погодинний Прогноз
                                    Text("Погодинний Прогноз (24 год)").font(.headline)
                                        .frame(maxWidth: .infinity, alignment: .leading).padding(.top, 20)

                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 12) {
                                            ForEach(viewModel.forecastItems, id: \.dt) { item in
                                                ForecastItemView(item: item)
                                            }
                                        }
                                    }
                                    .frame(height: 140)
                                    
                                    // MARK: - 2. 5-денний Прогноз
                                    Text("Прогноз на 5 днів").font(.title2).bold()
                                        .frame(maxWidth: .infinity, alignment: .leading).padding(.top, 20)

                                    ForEach(viewModel.dailyForecast, id: \.dt) { item in
                                        DailyForecastItemView(item: item)
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.bottom, 20)
                                
                            }
                            
                            // Заглушка, якщо даних немає
                            else if !viewModel.isLoading && viewModel.errorMessage == nil {
                                Spacer()
                                Text("Введіть місто для перегляду погоди").foregroundColor(.white.opacity(0.8))
                                Spacer()
                            }
                            
                        }
                        // 🛑 КЛЮЧОВЕ ВИПРАВЛЕННЯ: minHeight = висота GeometryReader - приблизна висота верхніх елементів (приблизно 100pt)
                        .frame(minHeight: geometry.size.height - 100)
                        
                    }
                }
                .padding(.top, 10)
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.8), radius: 5, x: 0, y: 2)
                .background(Color.clear) 
            }
        }
        .onAppear {
            if viewModel.currentWeather == nil {
                viewModel.fetchWeather(viewModel.currentCity)
            }
        }
    }
}
