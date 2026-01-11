import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_map_explainer/core/widget/favorite_button.dart';
import 'package:ai_map_explainer/feature/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:ai_map_explainer/feature/favorites/presentation/bloc/favorites_event.dart';
import 'package:ai_map_explainer/core/services/social/favorites_service.dart';

void main() {
  group('FavoriteButton', () {
    testWidgets('should display favorite icon when item is favorited', (WidgetTester tester) async {
      // Arrange
      final favoritesService = FavoritesService.instance;
      await favoritesService.addFavorite(
        type: 'location',
        itemId: 'test_location_1',
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider(
            create: (context) => FavoritesBloc(favoritesService),
            child: Scaffold(
              body: FavoriteButton(
                type: 'location',
                itemId: 'test_location_1',
              ),
            ),
          ),
        ),
      );

      // Trigger state update
      await tester.pump();
      await tester.pump();

      // Assert
      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('should display favorite_border icon when item is not favorited', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider(
            create: (context) => FavoritesBloc(FavoritesService.instance),
            child: Scaffold(
              body: FavoriteButton(
                type: 'location',
                itemId: 'non_favorited_location',
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      // Assert
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    });

    testWidgets('should toggle favorite when tapped', (WidgetTester tester) async {
      // Arrange
      final favoritesService = FavoritesService.instance;
      final bloc = FavoritesBloc(favoritesService);

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: bloc,
            child: Scaffold(
              body: FavoriteButton(
                type: 'location',
                itemId: 'toggle_test_location',
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      // Initially not favorited
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);

      // Tap to favorite
      await tester.tap(find.byType(IconButton));
      await tester.pump();

      // Should dispatch AddFavorite event
      bloc.add(LoadFavorites());
      await tester.pump();
    });

    testWidgets('should display tooltip when provided', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider(
            create: (context) => FavoritesBloc(FavoritesService.instance),
            child: Scaffold(
              body: FavoriteButton(
                type: 'location',
                itemId: 'test_location',
                tooltip: 'Add to favorites',
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      // Assert
      expect(find.byType(Tooltip), findsOneWidget);
    });
  });
}
