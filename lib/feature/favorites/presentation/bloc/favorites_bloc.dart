import 'package:ai_map_explainer/core/services/social/favorites_service.dart';
import 'package:ai_map_explainer/core/utils/logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_map_explainer/feature/favorites/presentation/bloc/favorites_event.dart';
import 'package:ai_map_explainer/feature/favorites/presentation/bloc/favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final FavoritesService _favoritesService;

  FavoritesBloc(this._favoritesService) : super(const FavoritesInitial()) {
    on<FavoritesEvent>(_onEvent);
  }

  Future<void> _onEvent(FavoritesEvent event, Emitter<FavoritesState> emit) async {
    if (event is LoadFavorites) {
      await _onLoadFavorites(event, emit);
    } else if (event is AddFavorite) {
      await _onAddFavorite(event, emit);
    } else if (event is RemoveFavorite) {
      await _onRemoveFavorite(event, emit);
    } else if (event is CheckFavorite) {
      await _onCheckFavorite(event, emit);
    } else if (event is ClearAllFavorites) {
      await _onClearAllFavorites(emit);
    }
  }

  Future<void> _onLoadFavorites(LoadFavorites event, Emitter<FavoritesState> emit) async {
    emit(const FavoritesLoading());
    try {
      final favorites = event.type != null
          ? await _favoritesService.getAllFavorites(type: event.type)
          : await _favoritesService.getAllFavorites();
      emit(FavoritesLoaded(favorites: favorites, type: event.type));
    } catch (e, st) {
      Logger.e('Error loading favorites: $e', stackTrace: st);
      emit(FavoritesError(message: 'Không thể tải danh sách yêu thích'));
    }
  }

  Future<void> _onAddFavorite(AddFavorite event, Emitter<FavoritesState> emit) async {
    try {
      final success = await _favoritesService.addFavorite(
        type: event.type,
        itemId: event.itemId,
        title: event.title,
        metadata: event.metadata,
      );

      if (success) {
        // Reload favorites để cập nhật danh sách
        // Lấy type từ state hiện tại nếu có, hoặc từ event
        String? currentType;
        if (state is FavoritesLoaded) {
          currentType = (state as FavoritesLoaded).type;
        }
        final favorites = currentType != null
            ? await _favoritesService.getAllFavorites(type: currentType)
            : await _favoritesService.getAllFavorites();
        emit(FavoritesLoaded(favorites: favorites, type: currentType));
      }
    } catch (e, st) {
      Logger.e('Error adding favorite: $e', stackTrace: st);
      emit(FavoritesError(message: 'Không thể thêm vào yêu thích'));
    }
  }

  Future<void> _onRemoveFavorite(RemoveFavorite event, Emitter<FavoritesState> emit) async {
    try {
      final success = await _favoritesService.removeFavorite(
        type: event.type,
        itemId: event.itemId,
      );

      if (success) {
        // Reload favorites để cập nhật danh sách
        // Lấy type từ state hiện tại nếu có, hoặc từ event
        String? currentType;
        if (state is FavoritesLoaded) {
          currentType = (state as FavoritesLoaded).type;
        }
        final favorites = currentType != null
            ? await _favoritesService.getAllFavorites(type: currentType)
            : await _favoritesService.getAllFavorites();
        emit(FavoritesLoaded(favorites: favorites, type: currentType));
      }
    } catch (e, st) {
      Logger.e('Error removing favorite: $e', stackTrace: st);
      emit(FavoritesError(message: 'Không thể xóa khỏi yêu thích'));
    }
  }

  Future<void> _onCheckFavorite(CheckFavorite event, Emitter<FavoritesState> emit) async {
    try {
      final isFavorite = await _favoritesService.isFavorite(
        type: event.type,
        itemId: event.itemId,
      );
      emit(FavoriteStatus(
        isFavorite: isFavorite,
        type: event.type,
        itemId: event.itemId,
      ));
    } catch (e, st) {
      Logger.e('Error checking favorite: $e', stackTrace: st);
      emit(FavoriteStatus(
        isFavorite: false,
        type: event.type,
        itemId: event.itemId,
      ));
    }
  }

  Future<void> _onClearAllFavorites(Emitter<FavoritesState> emit) async {
    try {
      final success = await _favoritesService.clearAllFavorites();
      if (success) {
        emit(const FavoritesLoaded(favorites: []));
      }
    } catch (e, st) {
      Logger.e('Error clearing favorites: $e', stackTrace: st);
      emit(const FavoritesError(message: 'Không thể xóa tất cả yêu thích'));
    }
  }
}
