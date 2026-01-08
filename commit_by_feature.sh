#!/bin/bash

# Script để commit các features theo từng nhóm
# Chỉ commit các file chưa được track hoặc đã modified

echo "=== Committing Features by Group ==="
echo ""

# Function để check và add file
add_if_exists() {
    if [ -f "$1" ] && [ -n "$(git status --short "$1" 2>/dev/null)" ]; then
        echo "  Adding: $1"
        git add "$1"
        return 0
    else
        echo "  Skipping: $1 (already committed or not found)"
        return 1
    fi
}

# Feature 1: Historical Markers
echo "1. Historical Markers Feature..."
add_if_exists "lib/core/services/map/historical_location_model.dart"
add_if_exists "lib/core/services/map/historical_location_service.dart"
add_if_exists "assets/historical_locations.json"
add_if_exists "lib/feature/map/domain/map_repository.dart"
add_if_exists "lib/feature/map/domain/map_repository_impl.dart"
add_if_exists "lib/feature/map/domain/map_usecase.dart"
add_if_exists "lib/feature/map/presentation/bloc/map_event.dart"
add_if_exists "lib/feature/map/presentation/bloc/map_state.dart"
add_if_exists "lib/core/di/service_locator.dart"

if [ -n "$(git diff --cached --name-only)" ]; then
    git commit -m "feat: add historical markers on map

- Add HistoricalLocation model and service
- Load historical locations from JSON assets
- Display historical markers on map (red color)
- Tap marker to view details
- Auto-load when map opens"
    echo "  ✓ Committed Historical Markers"
else
    echo "  ⊘ No changes for Historical Markers"
fi
echo ""

# Feature 2: Marker Clustering
echo "2. Marker Clustering Feature..."
git reset
add_if_exists "lib/core/services/map/marker_cluster_service.dart"
# map_view.dart sẽ được commit riêng vì có nhiều thay đổi
if [ -n "$(git diff --cached --name-only)" ]; then
    git commit -m "feat: implement marker clustering

- Add MarkerClusterService for grouping nearby markers
- Cluster markers when zooming out
- Purple cluster markers with count display
- Tap cluster to zoom in
- Improve performance with many markers"
    echo "  ✓ Committed Marker Clustering Service"
else
    echo "  ⊘ No changes for Marker Clustering Service"
fi
echo ""

# Feature 3: Error Handling
echo "3. Error Handling Standardization..."
git reset
add_if_exists "lib/core/common/models/app_error.dart"
add_if_exists "lib/core/utils/error_converter.dart"
add_if_exists "lib/feature/map/domain/map_repository.dart"
add_if_exists "lib/feature/map/domain/map_repository_impl.dart"
add_if_exists "lib/feature/map/domain/map_usecase.dart"
add_if_exists "lib/feature/map/presentation/bloc/map_bloc.dart"
if [ -n "$(git diff --cached --name-only)" ]; then
    git commit -m "feat: standardize error handling with Either pattern

- Add AppError model with Freezed (Network, Location, API, Cache, Unknown)
- Add ErrorConverter to convert exceptions to AppError
- Update repository methods to return Either<AppError, T>
- Update UseCase and BLoC to handle Either results
- User-friendly error messages"
    echo "  ✓ Committed Error Handling"
else
    echo "  ⊘ No changes for Error Handling"
fi
echo ""

# Feature 4: Caching System
echo "4. Caching System..."
git reset
add_if_exists "lib/core/services/cache/cache_service.dart"
add_if_exists "lib/core/services/map/historical_location_service.dart"
add_if_exists "lib/feature/map/domain/map_repository_impl.dart"
if [ -n "$(git diff --cached --name-only)" ]; then
    git commit -m "feat: implement caching system with Hive

- Add CacheService for managing local cache
- Cache historical locations (24 hours)
- Cache AI responses (7 days)
- Cache Wikipedia data (30 days)
- Auto-clear expired cache"
    echo "  ✓ Committed Caching System"
else
    echo "  ⊘ No changes for Caching System"
fi
echo ""

# Feature 5: Dark Mode
echo "5. Dark Mode Feature..."
git reset
add_if_exists "lib/core/theme/app_theme.dart"
add_if_exists "lib/core/theme/theme_provider.dart"
add_if_exists "lib/feature/general/general_view.dart"
add_if_exists "lib/main.dart"
if [ -n "$(git diff --cached --name-only)" ]; then
    git commit -m "feat: add dark mode support

- Add AppTheme with Material 3 light/dark themes
- Add ThemeProvider to manage theme state
- Theme toggle button in General View
- Save theme preference to SharedPreferences"
    echo "  ✓ Committed Dark Mode"
else
    echo "  ⊘ No changes for Dark Mode"
fi
echo ""

# Feature 6: Reusable Widgets
echo "6. Reusable Widgets..."
git reset
add_if_exists "lib/core/widget/loading_widget.dart"
add_if_exists "lib/core/widget/error_widget.dart"
add_if_exists "lib/core/utils/error_message_helper.dart"
add_if_exists "lib/feature/history/presentation/history_view.dart"
add_if_exists "lib/feature/detail/detail_view.dart"
if [ -n "$(git diff --cached --name-only)" ]; then
    git commit -m "feat: add reusable loading and error widgets

- Add LoadingWidget with 4 styles (centered, inline, minimal, fullScreen)
- Add ErrorDisplayWidget with 4 styles (centered, inline, banner, fullScreen)
- Add ErrorMessageHelper for user-friendly error messages
- Replace LoadingIndicator with LoadingWidget across app
- Consistent error handling UI"
    echo "  ✓ Committed Reusable Widgets"
else
    echo "  ⊘ No changes for Reusable Widgets"
fi
echo ""

# Feature 7: Localization
echo "7. Localization Feature..."
git reset
add_if_exists "lib/l10n/app_en.arb"
add_if_exists "lib/l10n/app_vi.arb"
add_if_exists "lib/l10n/app_localizations.dart"
add_if_exists "lib/l10n/app_localizations_en.dart"
add_if_exists "lib/l10n/app_localizations_vi.dart"
add_if_exists "lib/core/localization/locale_provider.dart"
add_if_exists "l10n.yaml"
add_if_exists "LOCALIZATION_SETUP.md"
# Các file đã được localize (sẽ commit riêng nếu cần)
if [ -n "$(git diff --cached --name-only)" ]; then
    git commit -m "feat: add localization support (Vietnamese & English)

- Setup Flutter localization with ARB files
- Add LocaleProvider to manage language state
- Language switcher in General View
- Localize all strings in app
- Save language preference to SharedPreferences"
    echo "  ✓ Committed Localization"
else
    echo "  ⊘ No changes for Localization"
fi
echo ""

# Feature 8: Documentation
echo "8. Documentation..."
git reset
add_if_exists "BUILD_INSTRUCTIONS.md"
add_if_exists "CHANGELOG.md"
add_if_exists "COMMIT_GUIDE.md"
if [ -n "$(git diff --cached --name-only)" ]; then
    git commit -m "docs: update build instructions and changelog

- Add BUILD_INSTRUCTIONS.md with feature setup guide
- Add CHANGELOG.md documenting all new features
- Add COMMIT_GUIDE.md for feature-based commits"
    echo "  ✓ Committed Documentation"
else
    echo "  ⊘ No changes for Documentation"
fi
echo ""

# Fix nhỏ: map_view.dart
echo "9. Map View Fix..."
git reset
if [ -n "$(git status --short lib/feature/map/presentation/view/map_view.dart)" ]; then
    git add lib/feature/map/presentation/view/map_view.dart
    git commit -m "fix: remove const from Row with localization

- Fix const Row issue when using AppLocalizations
- Update marker clustering integration"
    echo "  ✓ Committed Map View Fix"
else
    echo "  ⊘ No changes for Map View"
fi
echo ""

# Pubspec và lock file
echo "10. Dependencies Update..."
git reset
if [ -n "$(git status --short pubspec.yaml)" ]; then
    git add pubspec.yaml
    git commit -m "chore: update dependencies

- Add flutter_localizations
- Add provider for state management
- Update intl to 0.20.2
- Add flutter_gen"
    echo "  ✓ Committed Dependencies"
fi
if [ -n "$(git status --short pubspec.lock)" ]; then
    git add pubspec.lock
    git commit -m "chore: update pubspec.lock"
    echo "  ✓ Committed pubspec.lock"
fi
echo ""

echo "=== Done! ==="
echo "Run 'git log --oneline -15' to see all commits"
