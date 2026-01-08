#!/bin/bash

# Script để commit các features theo từng nhóm

echo "=== Committing Features ==="

# 1. Historical Markers Feature
echo "1. Committing Historical Markers feature..."
git add lib/core/services/map/historical_location_model.dart
git add lib/core/services/map/historical_location_service.dart
git add assets/historical_locations.json
git add lib/feature/map/domain/map_repository.dart
git add lib/feature/map/domain/map_repository_impl.dart
git add lib/feature/map/domain/map_usecase.dart
git add lib/feature/map/presentation/bloc/map_event.dart
git add lib/feature/map/presentation/bloc/map_state.dart
git add lib/core/di/service_locator.dart
git commit -m "feat: add historical markers on map

- Add HistoricalLocation model and service
- Load historical locations from JSON assets
- Display historical markers on map (red color)
- Tap marker to view details
- Auto-load when map opens"

# 2. Marker Clustering Feature
echo "2. Committing Marker Clustering feature..."
git add lib/core/services/map/marker_cluster_service.dart
git add lib/feature/map/presentation/view/map_view.dart
git commit -m "feat: implement marker clustering

- Add MarkerClusterService for grouping nearby markers
- Cluster markers when zooming out
- Purple cluster markers with count display
- Tap cluster to zoom in
- Improve performance with many markers"

# 3. Error Handling Standardization
echo "3. Committing Error Handling Standardization..."
git add lib/core/common/models/app_error.dart
git add lib/core/utils/error_converter.dart
git add lib/feature/map/domain/map_repository.dart
git add lib/feature/map/domain/map_repository_impl.dart
git add lib/feature/map/domain/map_usecase.dart
git add lib/feature/map/presentation/bloc/map_bloc.dart
git commit -m "feat: standardize error handling with Either pattern

- Add AppError model with Freezed (Network, Location, API, Cache, Unknown)
- Add ErrorConverter to convert exceptions to AppError
- Update repository methods to return Either<AppError, T>
- Update UseCase and BLoC to handle Either results
- User-friendly error messages"

# 4. Caching System
echo "4. Committing Caching System..."
git add lib/core/services/cache/cache_service.dart
git add lib/core/services/map/historical_location_service.dart
git add lib/feature/map/domain/map_repository_impl.dart
git add pubspec.yaml
git commit -m "feat: implement caching system with Hive

- Add CacheService for managing local cache
- Cache historical locations (24 hours)
- Cache AI responses (7 days)
- Cache Wikipedia data (30 days)
- Auto-clear expired cache"

# 5. Dark Mode
echo "5. Committing Dark Mode feature..."
git add lib/core/theme/app_theme.dart
git add lib/core/theme/theme_provider.dart
git add lib/feature/general/general_view.dart
git add lib/main.dart
git add pubspec.yaml
git commit -m "feat: add dark mode support

- Add AppTheme with Material 3 light/dark themes
- Add ThemeProvider to manage theme state
- Theme toggle button in General View
- Save theme preference to SharedPreferences"

# 6. Reusable Widgets
echo "6. Committing Reusable Widgets..."
git add lib/core/widget/loading_widget.dart
git add lib/core/widget/error_widget.dart
git add lib/core/utils/error_message_helper.dart
git add lib/feature/history/presentation/history_view.dart
git add lib/feature/detail/detail_view.dart
git commit -m "feat: add reusable loading and error widgets

- Add LoadingWidget with 4 styles (centered, inline, minimal, fullScreen)
- Add ErrorDisplayWidget with 4 styles (centered, inline, banner, fullScreen)
- Add ErrorMessageHelper for user-friendly error messages
- Replace LoadingIndicator with LoadingWidget across app
- Consistent error handling UI"

# 7. Localization (if not already committed)
echo "7. Committing Localization feature..."
git add lib/l10n/app_en.arb
git add lib/l10n/app_vi.arb
git add lib/l10n/app_localizations.dart
git add lib/l10n/app_localizations_en.dart
git add lib/l10n/app_localizations_vi.dart
git add lib/core/localization/locale_provider.dart
git add lib/main.dart
git add lib/feature/general/general_view.dart
git add lib/feature/map/presentation/view/map_view.dart
git add lib/feature/history/presentation/history_view.dart
git add lib/feature/chat/presentation/view/chat_view.dart
git add lib/feature/detail/detail_view.dart
git add lib/feature/app_bottom_navigation.dart
git add l10n.yaml
git add pubspec.yaml
git add LOCALIZATION_SETUP.md
git commit -m "feat: add localization support (Vietnamese & English)

- Setup Flutter localization with ARB files
- Add LocaleProvider to manage language state
- Language switcher in General View
- Localize all strings in app
- Save language preference to SharedPreferences"

# 8. Documentation
echo "8. Committing Documentation..."
git add BUILD_INSTRUCTIONS.md
git add CHANGELOG.md
git commit -m "docs: update build instructions and changelog

- Add BUILD_INSTRUCTIONS.md with feature setup guide
- Add CHANGELOG.md documenting all new features"

echo "=== All features committed! ==="
echo "Run 'git log --oneline -10' to see commits"
