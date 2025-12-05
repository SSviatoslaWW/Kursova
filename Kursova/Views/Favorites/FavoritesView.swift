import SwiftUI

struct FavoritesView: View {
    @ObservedObject var favoritesVM: FavoritesViewModel
    @ObservedObject var weatherVM: WeatherViewModel
    
    let onCitySelect: (FavoriteLocation) -> Void
    let onClose: () -> Void
    
    @State private var isEditing: Bool = false
    
    // MARK: - Body
    
    var body: some View {
        GeometryReader {geo in
            ZStack {
                Image(WeatherViewModel.getBackground(for: weatherVM.currentWeather?.weather.first?.main))
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .ignoresSafeArea()
                    .overlay(
                        Color.black
                            .opacity(0.5)
                            .ignoresSafeArea()
                    )
                VStack(spacing: 0) {
                    FavoritesHeaderView(
                        isEditing: $isEditing,
                        showEditButton: favoritesVM.shouldShowEditButton,
                        onGeolocationTap: {
                            weatherVM.forceRefreshUserLocation()
                            onClose()
                        }
                    )
                    
                    if favoritesVM.favoriteLocations.isEmpty {
                        FavoritesEmptyStateView()
                            .frame(maxWidth: geo.size.width)
                            .frame(maxHeight: .infinity)
                        
                    } else {
                        List {
                            ForEach(Array(favoritesVM.favoriteLocations.enumerated()), id: \.element.uid) { index, location in
                                CityCardRow(
                                    location: location,
                                    index: index,
                                    isEditing: isEditing,
                                    favoritesVM: favoritesVM,
                                    onSelect: {
                                        onCitySelect(location)
                                    }
                                )
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                            }
                            .onDelete { offsets in
                                withAnimation(.spring()) {
                                    favoritesVM.removeLocation(at: offsets)
                                }
                            }
                        }
                        .scrollBounceBehavior(.basedOnSize)
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden) // щоб був видимий твій background
                    }
                    
                }
                .foregroundColor(.white)
                .onChange(of: favoritesVM.favoriteLocations) { oldValue, newValue in
                    if newValue.isEmpty && isEditing {
                        withAnimation(.spring()) {
                            isEditing = false
                        }
                    }
                }
            }
        }
        //.ignoresSafeArea()
    }
}
