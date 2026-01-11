# Collections Feature

## Setup Required

### 1. Generate Freezed Files

Collections feature sử dụng Freezed để generate code cho events và states. Bạn cần chạy build_runner để generate các files:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Hoặc nếu muốn watch mode (tự động rebuild khi có thay đổi):

```bash
flutter pub run build_runner watch --delete-conflicting-outputs
```

### 2. Generate Localization Files

Sau khi thêm các localization strings mới, chạy:

```bash
flutter gen-l10n
```

## Cấu trúc

- **Service**: `lib/core/services/social/collections_service.dart`
  - Quản lý collections và items với Hive storage
  
- **UseCase**: `lib/feature/collections/domain/collections_usecase.dart`
  - Business logic layer với error handling
  
- **Bloc**: `lib/feature/collections/presentation/bloc/`
  - State management với Freezed
  
- **View**: `lib/feature/collections/presentation/view/collections_view.dart`
  - UI để quản lý collections
  
- **Components**: `lib/feature/collections/presentation/components/`
  - Reusable components cho collections

## Sử dụng

### Thêm item vào collection

```dart
AddToCollectionButton(
  type: 'location',
  itemId: location.id,
  title: location.name,
)
```

### Navigate to Collections

```dart
Routes.router.navigateTo(
  context,
  RoutePath.collections,
);
```

## Lưu ý

- Tất cả các lỗi compile sẽ biến mất sau khi chạy `build_runner`
- Collections được lưu local với Hive
- Mỗi collection có thể chứa cả locations và chats
