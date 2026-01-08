import 'package:ai_map_explainer/core/services/social/favorites_service.dart';
import 'package:ai_map_explainer/core/utils/enum/load_state.dart';

/// Favorites states
sealed class FavoritesState {
  const FavoritesState();
}

class FavoritesInitial extends FavoritesState {
  const FavoritesInitial();
}

class FavoritesLoading extends FavoritesState {
  const FavoritesLoading();
}

class FavoritesLoaded extends FavoritesState {
  final List<FavoriteItem> favorites;
  final String? type;
  const FavoritesLoaded({
    required this.favorites,
    this.type,
  });
}

class FavoriteStatus extends FavoritesState {
  final bool isFavorite;
  final String type;
  final String itemId;
  const FavoriteStatus({
    required this.isFavorite,
    required this.type,
    required this.itemId,
  });
}

class FavoritesError extends FavoritesState {
  final String message;
  final LoadState loadState;
  const FavoritesError({
    required this.message,
    this.loadState = LoadState.failure,
  });
}
