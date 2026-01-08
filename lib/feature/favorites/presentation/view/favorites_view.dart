import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_map_explainer/core/services/social/favorites_service.dart';
import 'package:ai_map_explainer/core/services/map/historical_location_model.dart';
import 'package:ai_map_explainer/core/services/map/historical_location_service.dart';
import 'package:ai_map_explainer/core/widget/enhanced_empty_state.dart';
import 'package:ai_map_explainer/core/widget/loading_widget.dart';
import 'package:ai_map_explainer/core/widget/favorite_button.dart';
import 'package:ai_map_explainer/core/widget/share_button.dart';
import 'package:ai_map_explainer/feature/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:ai_map_explainer/feature/favorites/presentation/bloc/favorites_event.dart';
import 'package:ai_map_explainer/feature/favorites/presentation/bloc/favorites_state.dart';
import 'package:ai_map_explainer/l10n/app_localizations.dart';
import 'package:gap/gap.dart';

class FavoritesView extends StatefulWidget {
  const FavoritesView({super.key});

  @override
  State<FavoritesView> createState() => _FavoritesViewState();
}

class _FavoritesViewState extends State<FavoritesView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedType = 'all'; // 'all', 'location', 'chat'

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    context.read<FavoritesBloc>().add(const LoadFavorites());
  }

  void _onTabChanged() {
    final index = _tabController.index;
    setState(() {
      _selectedType = index == 0 ? 'all' : (index == 1 ? 'location' : 'chat');
    });
    context.read<FavoritesBloc>().add(LoadFavorites(type: _selectedType == 'all' ? null : _selectedType));
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorites'), // TODO: Use l10n?.favorites after running flutter gen-l10n
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Locations'),
            Tab(text: 'Chats'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear all', // TODO: Use l10n?.clearAll after running flutter gen-l10n
            onPressed: () => _showClearAllDialog(context),
          ),
        ],
      ),
      body: BlocBuilder<FavoritesBloc, FavoritesState>(
        builder: (context, state) {
          if (state is FavoritesLoading) {
            return const LoadingWidget(style: LoadingStyle.centered);
          }

          if (state is FavoritesError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  const Gap(16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<FavoritesBloc>().add(LoadFavorites(
                        type: _selectedType == 'all' ? null : _selectedType,
                      ));
                    },
                    child: Text(l10n?.retry ?? 'Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is FavoritesLoaded) {
            if (state.favorites.isEmpty) {
              return EnhancedEmptyState.noData(
                title: 'No favorites yet', // TODO: Use l10n?.noFavorites after running flutter gen-l10n
                message: 'Start favoriting locations and chats to see them here.', // TODO: Use l10n?.noFavoritesMessage after running flutter gen-l10n
                onRefresh: () {
                  context.read<FavoritesBloc>().add(LoadFavorites(
                    type: _selectedType == 'all' ? null : _selectedType,
                  ));
                },
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.favorites.length,
              itemBuilder: (context, index) {
                final favorite = state.favorites[index];
                return _buildFavoriteItem(context, favorite);
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildFavoriteItem(BuildContext context, FavoriteItem favorite) {
    if (favorite.type == 'location') {
      return _buildLocationItem(context, favorite);
    } else {
      return _buildChatItem(context, favorite);
    }
  }

  Widget _buildLocationItem(BuildContext context, FavoriteItem favorite) {
    return FutureBuilder<HistoricalLocation?>(
      future: _getLocationById(favorite.itemId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final location = snapshot.data!;
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            location.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Gap(4),
                          Wrap(
                            spacing: 8,
                            children: [
                              Chip(
                                label: Text(location.type),
                                backgroundColor: Colors.blueGrey.shade100,
                                labelStyle: const TextStyle(fontSize: 12),
                              ),
                              Chip(
                                label: Text(location.period),
                                backgroundColor: Colors.blueGrey.shade100,
                                labelStyle: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FavoriteButton(
                          type: 'location',
                          itemId: location.id,
                          title: location.name,
                        ),
                        ShareButton(
                          content: ShareLocation(location),
                        ),
                      ],
                    ),
                  ],
                ),
                if (location.description.isNotEmpty) ...[
                  const Gap(8),
                  Text(
                    location.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (location.address != null && location.address!.isNotEmpty) ...[
                  const Gap(8),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          location.address!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                const Gap(8),
                Text(
                  'Added ${_formatDate(favorite.createdAt)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildChatItem(BuildContext context, FavoriteItem favorite) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    favorite.title ?? 'Chat',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Gap(4),
                  Text(
                    'Added ${_formatDate(favorite.createdAt)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FavoriteButton(
                  type: 'chat',
                  itemId: favorite.itemId,
                  title: favorite.title,
                ),
                ShareButton(
                  content: ShareChat(
                    title: favorite.title ?? 'Chat',
                    content: favorite.metadata?['content'] ?? '',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<HistoricalLocation?> _getLocationById(String id) async {
    try {
      final locations = await HistoricalLocationService.instance.loadHistoricalLocations();
      return locations.firstWhere(
        (loc) => loc.id == id,
        orElse: () => throw Exception('Location not found'),
      );
    } catch (e) {
      return null;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  Future<void> _showClearAllDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear all'), // TODO: Use l10n?.clearAll after running flutter gen-l10n
        content: const Text(
          'Are you sure you want to clear all favorites?', // TODO: Use l10n?.clearAllFavoritesConfirm after running flutter gen-l10n
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear all'), // TODO: Use l10n?.clearAll after running flutter gen-l10n
          ),
        ],
      ),
    );

    if (confirmed == true) {
      context.read<FavoritesBloc>().add(const ClearAllFavorites());
    }
  }
}
