import SwiftUI

struct FavoritesView: View {
    @ObservedObject var favoritesVM: FavoritesViewModel
    @ObservedObject var weatherVM: WeatherViewModel
    
    let onCitySelect: (FavoriteLocation) -> Void
    let onClose: () -> Void
    
    @State private var isEditing: Bool = false
    
    // MARK: - Body
    
    var body: some View {
        GeometryReader {_ in
            ZStack {
                Image(weatherVM.getBackground())
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .overlay(
                        Color.black
                            .opacity(0.5)
                            .ignoresSafeArea()
                    )
            }
            
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
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(favoritesVM.favoriteLocations.indices, id: \.self) { index in
                                if index < favoritesVM.favoriteLocations.count {
                                    let location = favoritesVM.favoriteLocations[index]
                                    
                                    CityCardRow(
                                        location: location,
                                        index: index,
                                        isEditing: isEditing,
                                        favoritesVM: favoritesVM,
                                        onSelect: {
                                            onCitySelect(location)
                                        }
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 10)
                    }
                    .scrollBounceBehavior(.basedOnSize)
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
}
