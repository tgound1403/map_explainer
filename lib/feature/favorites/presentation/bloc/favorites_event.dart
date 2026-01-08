/// Favorites events
sealed class FavoritesEvent {
  const FavoritesEvent();
}

class LoadFavorites extends FavoritesEvent {
  final String? type; // 'location' hoặc 'chat' hoặc null cho tất cả
  const LoadFavorites({this.type});
}

class AddFavorite extends FavoritesEvent {
  final String type;
  final String itemId;
  final String? title;
  final Map<String, dynamic>? metadata;
  const AddFavorite({
    required this.type,
    required this.itemId,
    this.title,
    this.metadata,
  });
}

class RemoveFavorite extends FavoritesEvent {
  final String type;
  final String itemId;
  const RemoveFavorite({
    required this.type,
    required this.itemId,
  });
}

class CheckFavorite extends FavoritesEvent {
  final String type;
  final String itemId;
  const CheckFavorite({
    required this.type,
    required this.itemId,
  });
}

class ClearAllFavorites extends FavoritesEvent {
  const ClearAllFavorites();
}
