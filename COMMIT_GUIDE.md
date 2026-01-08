# Hướng Dẫn Commit Theo Feature

Dựa vào các thay đổi, đây là cách commit theo từng feature:

## Feature 1: Historical Markers
```bash
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
```

## Feature 2: Marker Clustering
```bash
git add lib/core/services/map/marker_cluster_service.dart
git add lib/feature/map/presentation/view/map_view.dart
git commit -m "feat: implement marker clustering

- Add MarkerClusterService for grouping nearby markers
- Cluster markers when zooming out
- Purple cluster markers with count display
- Tap cluster to zoom in
- Improve performance with many markers"
```

## Feature 3: Error Handling Standardization
```bash
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
```

## Feature 4: Caching System
```bash
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
```

## Feature 5: Dark Mode
```bash
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
```

## Feature 6: Reusable Widgets
```bash
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
```

## Feature 7: Localization (nếu chưa commit)
```bash
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
```

## Feature 8: Documentation
```bash
git add BUILD_INSTRUCTIONS.md
git add CHANGELOG.md
git commit -m "docs: update build instructions and changelog

- Add BUILD_INSTRUCTIONS.md with feature setup guide
- Add CHANGELOG.md documenting all new features"
```

## Fix nhỏ: Const fix trong map_view
```bash
git add lib/feature/map/presentation/view/map_view.dart
git commit -m "fix: remove const from Row with localization"
```

## Lưu ý:
- Kiểm tra từng file trước khi add: `git status`
- Nếu file đã được commit trong commit trước, bỏ qua
- Chạy `git log --oneline` để xem các commit đã tạo
- Có thể sử dụng `git add -p` để review từng thay đổi
