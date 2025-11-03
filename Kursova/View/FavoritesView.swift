import SwiftUI

struct FavoritesView: View {
    @ObservedObject var favoritesVM: FavoritesViewModel
    @ObservedObject var weatherVM: WeatherViewModel
    
    // Приймає замикання з ContentView для обробки натискання на місто
    let onCitySelect: (String) -> Void
    
    //перемикач режипу редагування
    @State private var isEditing: Bool = false
    
    // MARK: - Body
    
    var body: some View {
        GeometryReader {_ in 
            ZStack {
                // Фон, який динамічно змінюється, синхронізуючись з головним екраном
                Image(weatherVM.getBackground())
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

            }
            // Основний контейнер для контенту
            VStack(spacing: 0) {
                HeaderView(
                    isEditing: $isEditing,
                    showEditButton: favoritesVM.shouldShowEditButton
                )
                
                if favoritesVM.favoriteCities.isEmpty {
                    EmptyStateView()
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(favoritesVM.favoriteCities.indices, id: \.self) { index in
                                let city = favoritesVM.favoriteCities[index]
                                
                                CityCardRow(
                                    city: city,
                                    index: index,
                                    isEditing: isEditing,
                                    favoritesVM: favoritesVM,
                                    onSelect: {
                                        onCitySelect(city)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 10)
                    }
                    .scrollBounceBehavior(.basedOnSize)
                }
            }
            .foregroundColor(.white)
            // Ми отримуємо старе і нове значення, але використовуємо тільки нове
            .onChange(of: favoritesVM.favoriteCities) { oldValue, newValue in
                // Якщо новий масив порожній і ми все ще в режимі редагування
                if newValue.isEmpty && isEditing {
                    withAnimation(.spring()) {
                        isEditing = false
                    }
                }
            }
        }
        
    }
    
    // MARK: - Внутрішні компоненти UI (Subviews)
    
    private struct EmptyStateView: View {
        var body: some View {
            Text("Міста, які ви додасте до улюблених, з'являться тут.")
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundColor(.white.opacity(0.8))
                .padding(.top, 50)
                .padding(.horizontal)
        }
    }
    
    private struct HeaderView: View {
        @Binding var isEditing: Bool
        let showEditButton: Bool

        var body: some View {
            HStack {
                Text("Улюблені")
                    .font(.largeTitle).bold()
                    Spacer()
                
                if showEditButton {
                    Button(isEditing ? "Готово" : "Змінити") {
                        withAnimation(.spring()) {
                            isEditing.toggle()
                        }
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .transition(.opacity.combined(with: .scale))
                }
            }
            .padding(.top, 50)
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
            .animation(.spring(), value: showEditButton)
        }
    }
    
    private struct CityCardRow: View {
        let city: String
        let index: Int
        let isEditing: Bool
        @ObservedObject var favoritesVM: FavoritesViewModel
        let onSelect: () -> Void

        var body: some View {
            HStack(spacing: 15) {
                if isEditing {
                    Button(action: {
                        withAnimation(.spring()) {
                            favoritesVM.removeCity(at: IndexSet(integer: index))
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color(white: 0.9).opacity(0.9))
                                .frame(width: 30, height: 30)

                            Image(systemName: "minus.circle.fill")
                                .foregroundColor(.red)
                                .font(.title)
                        }
                    }
                    .transition(.move(edge: .leading).combined(with: .opacity))
                }

                Button(action: {
                    if !isEditing {
                        onSelect()
                    }
                }) {
                    HStack {
                        Text(city)
                            .font(.title2)
                            .fontWeight(.medium)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(12)
                }
                //.buttonStyle(.plain)
            }
        }
    }
}

