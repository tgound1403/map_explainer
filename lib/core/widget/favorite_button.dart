import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_map_explainer/feature/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:ai_map_explainer/feature/favorites/presentation/bloc/favorites_event.dart';
import 'package:ai_map_explainer/feature/favorites/presentation/bloc/favorites_state.dart';

/// Button để toggle favorite
class FavoriteButton extends StatelessWidget {
  final String type; // 'location' hoặc 'chat'
  final String itemId;
  final String? title;
  final Map<String, dynamic>? metadata;
  final Color? iconColor;
  final double? iconSize;
  final String? tooltip;

  const FavoriteButton({
    super.key,
    required this.type,
    required this.itemId,
    this.title,
    this.metadata,
    this.iconColor,
    this.iconSize,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesBloc, FavoritesState>(
      builder: (context, state) {
        bool isFavorite = false;

        // Check current favorite status
        if (state is FavoriteStatus &&
            state.type == type &&
            state.itemId == itemId) {
          isFavorite = state.isFavorite;
        } else {
          // Check on mount
          context.read<FavoritesBloc>().add(CheckFavorite(
                type: type,
                itemId: itemId,
              ));
        }

        return IconButton(
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite
                ? Colors.red
                : (iconColor ?? Theme.of(context).iconTheme.color),
            size: iconSize ?? 24,
          ),
          tooltip: tooltip ?? (isFavorite ? 'Bỏ yêu thích' : 'Thêm vào yêu thích'),
          onPressed: () {
            if (isFavorite) {
              context.read<FavoritesBloc>().add(RemoveFavorite(
                    type: type,
                    itemId: itemId,
                  ));
            } else {
              context.read<FavoritesBloc>().add(AddFavorite(
                    type: type,
                    itemId: itemId,
                    title: title,
                    metadata: metadata,
                  ));
            }
          },
        );
      },
    );
  }
}
