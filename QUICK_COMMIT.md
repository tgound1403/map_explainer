# Quick Commit Guide

## Cách 1: Sử dụng Script Tự Động (Khuyến nghị)

```bash
./commit_by_feature.sh
```

Script này sẽ tự động:
- Kiểm tra file nào đã được commit
- Chỉ commit các file chưa được track hoặc đã modified
- Tạo commit message theo từng feature

## Cách 2: Commit Thủ Công Theo Hướng Dẫn

Xem file `COMMIT_GUIDE.md` để có hướng dẫn chi tiết từng bước.

## Cách 3: Commit Tất Cả Theo Feature (Nếu chưa commit gì)

Nếu bạn muốn commit tất cả thay đổi một lần theo từng feature:

```bash
# 1. Historical Markers
git add lib/core/services/map/historical_location* assets/historical_locations.json
git add lib/feature/map/domain/map_* lib/feature/map/presentation/bloc/map_*
git add lib/core/di/service_locator.dart
git commit -m "feat: add historical markers on map"

# 2. Marker Clustering  
git add lib/core/services/map/marker_cluster_service.dart
git commit -m "feat: implement marker clustering"

# 3. Error Handling
git add lib/core/common/models/app_error.dart lib/core/utils/error_converter.dart
git add lib/feature/map/domain/map_repository* lib/feature/map/domain/map_usecase.dart
git add lib/feature/map/presentation/bloc/map_bloc.dart
git commit -m "feat: standardize error handling with Either pattern"

# 4. Caching
git add lib/core/services/cache/cache_service.dart
git commit -m "feat: implement caching system with Hive"

# 5. Dark Mode
git add lib/core/theme/* lib/feature/general/general_view.dart lib/main.dart
git commit -m "feat: add dark mode support"

# 6. Reusable Widgets
git add lib/core/widget/loading_widget.dart lib/core/widget/error_widget.dart
git add lib/core/utils/error_message_helper.dart
git commit -m "feat: add reusable loading and error widgets"

# 7. Localization
git add lib/l10n/* lib/core/localization/* l10n.yaml LOCALIZATION_SETUP.md
git add lib/main.dart lib/feature/*/presentation/*/*.dart
git commit -m "feat: add localization support (Vietnamese & English)"

# 8. Documentation
git add BUILD_INSTRUCTIONS.md CHANGELOG.md COMMIT_GUIDE.md
git commit -m "docs: update documentation"

# 9. Fixes
git add lib/feature/map/presentation/view/map_view.dart
git commit -m "fix: remove const from Row with localization"

# 10. Dependencies
git add pubspec.yaml pubspec.lock
git commit -m "chore: update dependencies"
```

## Kiểm Tra Trước Khi Commit

```bash
# Xem tất cả thay đổi
git status

# Xem diff của một file cụ thể
git diff <file_path>

# Xem các file đã được commit trong commit gần nhất
git show --name-only HEAD
```

## Lưu Ý

- **Không commit**: `.fvmrc`, `.vscode/`, `android/app/.cxx/`, `ios/build/`, `test/` (nếu chưa có tests)
- **Nên commit**: Tất cả file `.dart`, `.yaml`, `.md`, `.json` (trừ generated files)
- Generated files (`.g.dart`, `.freezed.dart`) thường được ignore trong `.gitignore`
